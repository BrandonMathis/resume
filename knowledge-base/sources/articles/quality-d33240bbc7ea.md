# Quality

URL: https://medium.com/@brandonmathis/quality-d33240bbc7ea
RSS publication date: Thu, 23 May 2019 14:54:47 GMT
Retrieved: 2026-11-04
Source: Medium RSS; plain-text derivative. Original HTML is preserved in `sources/web/research-5.json`. Embedded code may be links only. Original publication dates, when stated, appear below.

(originally published 12 Aug 2015)

We often speak of “Quality Software” and “Quality Code” but what does that mean? What identifies a quality piece of software and why should anyone care? What makes a product “high quality?” A co-worker recently asked me these questions so I decided to write this blog post to answer them.

Quality is a Journey, not a destination

You cannot just build quality software. Quality is achieved through quality-focused development practices and discipline. Things like code-review, high attention to detail, and a desire to craft elegant code leads to high quality software. Because of this, a high desire to ship fast can result in lower quality since these practices do not lend themselves to speed. But, if you never ship then people will never see you work. The software you are creating will die on the vine and no one will care about your quality. It is a difficult balance to strike but if quality is kept in mind and appreciated at all phases of the software’s life-cycle then you can accelerate your development when the need arises without sacrificing quality. Once you sacrifice the portions of your process that re-enforce quality of work in order to “get this out the door” then you are destined to write software that is buggy, difficult to maintain, and low quality.

What makes software “High Quality”

I would personally say that the hallmark of high quality software is maintainability? If things fall apart the moment you add a new feature then you are working with low quality software. Your app should be as elegant on the inside as it is on the outside. Take, for example, the motherboard on the first computer that Apple ever made. The Apple I:

Apple II BoardNotice how the components on the board line up so intentionally. That was not done by accident. It was a concious decision made by Wozniak and Jobs when they were crafting their first PC. It was actually Jobs who insisted that the internals of the computer be arranged in such a manner. He cared deeply about quality not just on the outside shell of a product but on the inside too. He didn’t care if people opened the computer up or not but he did care that, if someone did open the computer, they were not assaulted with a rat-nest of wires and crooked hand-soldered transistors.

Why should you care about quality

Users may not see the internal workings of your app and they wont experience the development process that new features go through. Despite that, if you do not give those internals (the process, servers, code, and stylesheets) the attention that they need, then it will be the users that suffer. That one awesome feature that your user-base starts begging for could be the bane of your entire system because your codebase was not written in an easily extendable manner. Or that coder you bring on to help maintain your app could spend weeks grokking the codebase because someone didn’t care for quality and just implemented a complex mental model into code. It will take you forever to add a new feature and you will hear those words that developers love to say so often “We need to refactor this.”

Low quality code is:

Difficult to extend

Difficult to maintain

Difficult to debug

Difficult to support

Ignoring quality is like driving with a blind fold on. You can still go fast but you are destined to crash into a wall at some point.
