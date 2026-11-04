import * as SQLite from 'expo-sqlite';
import * as FileSystem from 'expo-file-system/legacy';
import * as MediaLibrary from 'expo-media-library';

import type { MemeEntry } from '@/context/MemeLibrary';

const MEMES_DIR = `${FileSystem.documentDirectory}memes/`;

let db: SQLite.SQLiteDatabase | null = null;

async function getDb(): Promise<SQLite.SQLiteDatabase> {
  if (!db) {
    db = await SQLite.openDatabaseAsync('meme-library.db');
    await db.execAsync(`
      CREATE TABLE IF NOT EXISTS memes (
        id TEXT PRIMARY KEY NOT NULL,
        uri TEXT NOT NULL,
        tags TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        isFavorite INTEGER NOT NULL DEFAULT 0
      );
    `);
    // Add isFavorite column for databases created before this migration
    try {
      await db.runAsync('ALTER TABLE memes ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0');
    } catch {
      // Column already exists, ignore
    }
  }
  return db;
}

async function ensureMemesDir(): Promise<void> {
  const dirInfo = await FileSystem.getInfoAsync(MEMES_DIR);
  if (!dirInfo.exists) {
    await FileSystem.makeDirectoryAsync(MEMES_DIR, { intermediates: true });
  }
}

export async function copyImageToLocal(sourceUri: string, id: string): Promise<string> {
  await ensureMemesDir();

  // Resolve ph:// (iOS photo library) assets to a copyable file URI
  let resolvedUri = sourceUri;
  if (sourceUri.startsWith('ph://')) {
    const assetId = sourceUri.replace('ph://', '').split('/')[0];
    const asset = await MediaLibrary.getAssetInfoAsync(assetId);
    resolvedUri = asset.localUri ?? sourceUri;
  }

  const extension = resolvedUri.split('.').pop()?.split('?')[0] || 'jpg';
  const localUri = `${MEMES_DIR}${id}.${extension}`;

  await FileSystem.copyAsync({ from: resolvedUri, to: localUri });
  return localUri;
}

export async function deleteLocalImage(uri: string): Promise<void> {
  try {
    const info = await FileSystem.getInfoAsync(uri);
    if (info.exists) {
      await FileSystem.deleteAsync(uri);
    }
  } catch {
    // Silently ignore deletion errors
  }
}

export async function getAllMemes(): Promise<MemeEntry[]> {
  const database = await getDb();
  const rows = await database.getAllAsync<{
    id: string;
    uri: string;
    tags: string;
    createdAt: number;
    isFavorite: number;
  }>('SELECT * FROM memes ORDER BY createdAt DESC');

  return rows.map((row) => ({
    id: row.id,
    uri: row.uri,
    tags: JSON.parse(row.tags),
    createdAt: row.createdAt,
    isFavorite: row.isFavorite === 1,
  }));
}

export async function insertMeme(meme: MemeEntry): Promise<void> {
  const database = await getDb();
  await database.runAsync(
    'INSERT INTO memes (id, uri, tags, createdAt, isFavorite) VALUES (?, ?, ?, ?, ?)',
    meme.id,
    meme.uri,
    JSON.stringify(meme.tags),
    meme.createdAt,
    meme.isFavorite ? 1 : 0,
  );
}

export async function removeMeme(id: string): Promise<string | null> {
  const database = await getDb();
  const row = await database.getFirstAsync<{ uri: string }>(
    'SELECT uri FROM memes WHERE id = ?',
    id,
  );
  await database.runAsync('DELETE FROM memes WHERE id = ?', id);
  return row?.uri ?? null;
}

export async function updateMemeFavorite(id: string, isFavorite: boolean): Promise<void> {
  const database = await getDb();
  await database.runAsync('UPDATE memes SET isFavorite = ? WHERE id = ?', isFavorite ? 1 : 0, id);
}

export async function updateMemeTags(id: string, tags: string[]): Promise<void> {
  const database = await getDb();
  await database.runAsync('UPDATE memes SET tags = ? WHERE id = ?', JSON.stringify(tags), id);
}

export async function destroyAll(): Promise<void> {
  const database = await getDb();
  await database.runAsync('DELETE FROM memes');

  try {
    const dirInfo = await FileSystem.getInfoAsync(MEMES_DIR);
    if (dirInfo.exists) {
      await FileSystem.deleteAsync(MEMES_DIR, { idempotent: true });
    }
  } catch {
    // Silently ignore cleanup errors
  }
}

export async function exportData(): Promise<string> {
  const memes = await getAllMemes();
  return JSON.stringify(memes, null, 2);
}
