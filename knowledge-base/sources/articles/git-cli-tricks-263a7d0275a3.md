# Git CLI Tricks

URL: https://medium.com/@brandonmathis/git-cli-tricks-263a7d0275a3
RSS publication date: Mon, 29 Jan 2024 20:51:45 GMT
Retrieved: 2026-11-04
Source: Medium RSS; plain-text derivative. Original HTML is preserved in `sources/web/research-5.json`. Embedded code may be links only. Original publication dates, when stated, appear below.

Using git scm is a key skillset for any aspiring software developer. If you are using GitHub, the GitHub Desktop application is a great way to get started. However, many of us still use or are forced to use git directly in the terminal. Here are some useful aliases and commands I’ve collected over the years to make my day-to-day experience with git easier.

Protip: Use git alias

You can define a git alias for git by dropping them in your ~/.gitconfig file like so

[alias]  a = add  aa = tomadd -A .  c = commit -m

Logging

Out of the box, git log is a pretty useless command. I use the following alias to make my logs far more descriptive. This alias will provide the git sha, date of commits and author name. It also builds a very useful visual graph of your branches and how they merge together.

[alias]  la = log --branches --date=short --graph --pretty=format:'%Cred%h%Creset %Cblue%ad%Creset %C(yellow)%aN%Creset %s%C(bold green)%d%Creset'

$ git la

I also use the following alias to group commits into a collection of changes introduced to master via a PR merge

[alias]  changes = log --pretty=format:\"%h %cr %cn %Cgreen%s%Creset\" --name-status

$ git changes

Saving WIP Changes

Often times, I find myself WIP on some code changes moments before a demo. I don’t want to show up to my demo with broken code so I use the following command to quickly stash my changes. Then I can clear them out without loosing my work.

[alias]  snapshot = !git stash save "snapshot: $(date)" && git stash apply "stash@{0}"  snapshots = !git stash list --grep snapshot

$ git snapshot# makes a new snapshot at stash@{0}$ git reset --hard HEAD# Rollback local uncommitted changes$ git clean -df# Clear out any new files that may have been created

I use this by running git snapshot to make a new stash of my changes and then can safely git reset --hard HEAD to get back to a stable state without my WIP changes. A git stash pop will quickly pop those changes out of the git stash

Pulling Down Changes

Any good developer should keep their local environment in-sync with the main branch on your remote git repo. We often do a git pull to accomplish this but this command can sometimes make a new merge commit if you have commits that have not been pushed AND changes on remote that have not been pulled down. I use this alias to avoid that:

[alias]  tug = pull --rebase

The --rebase option on the git pull command tells git to rebase your changes on top of the changes pulled down from the remote branch. I like to set this to a stand-alone alias so I always avoid creating unneeded merge commits

Other Helpful Stuff

Here are some other alias’ I use every day

[alias]  cob = checkout -b # Shorthand for creating new branches $ git cob <branch-name>  amend = commit --amend # ammend your last commit  di = diff # diff unstaged changes  # stash  ss = stash                        # stash changes  sl = stash list                   # list stashes  sa = stash apply                  # apply stash (restore changes)  sd = stash drop                   # drop stashes (destory changes)
