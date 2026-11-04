# Clojure, A Reflection On My Latest Obsession

URL: https://medium.com/@brandonmathis/clojure-a-reflection-on-my-latest-obsession-f175e1b2014f
RSS publication date: Thu, 23 May 2019 15:07:26 GMT
Retrieved: 2026-11-04
Source: Medium RSS; plain-text derivative. Original HTML is preserved in `sources/web/research-5.json`. Embedded code may be links only. Original publication dates, when stated, appear below.

(originally published 27 Jan 2016)

Every Friday we at Smashing Boxes take 4 hours out of the day to play explore our own personal interests and, for the past few months, I’ve been interested in Clojure. For the uninitiated, Clojure is a JVM based dialect of LISP. Clojure has a strong presence in the web development community via ClojurScript. But, I’m not here to talk about ClojurScript. I’m here to talk about Clojure and how it’s re-introduced me to crazy but beautify world of LISP and functional programming.

For the past few years, I’ve been very “anti functional” for no good reason. Maybe it has been my almost-fanatic obsession with Ruby and Object-Oriented programming, but functional programming is starting to influence my own personal coding style. Which is strange because one of my first introductions into programming was with Scheme, which has long stood as the de-facto implementation of LISP and the go-to functional programming language.

Actually, my first intro to computer programing was from the TI-83 calculator handbook. It’s brief chapter about TI BASIC which was the small programming language built into the TI-83.

I remember the first program I ever wrote. It consisted of about 50 print statements and a loop. When you ran the code, *’s would bounce from one side of the screen to the other. I guess the first thing I wanted to to with code was make cool shit happen on a screen.

After I learned TI-Basic, some time passed and I got into graphics programming. I played around a bit with DirectX but I did not find it very enjoyable. So I abandoned that passion and settled on building websites that did cool shit in a window on my screen. But, my desire to write code that just “does random things that looks cool” never died. I guess I was just born with a passion to make screen savers.

Quil

When a co-worker introduced me to Quil, I was intrigued. Quil is a carefully-crafted Clojure library built to make drawing and animation extremely easy. There are lots of examples of awesome animations written with the Quil library in Clojure that were well under 100 lines of code.

My pride a joy is a glitch-art effect I created that loads in an image, breaks it up into N 10x10 pixel squares, and then starts swapping those squares. This all started with me playing around with Quill’s blend function; trying out different effects and argument just to see what would come out on the other side. You can see the results of those experiments here. After a few hours of experimenting, I landed on this effect and it turned out really cool!

No only does it look cool, the Clojure code I wrote was crazy simple.

https://medium.com/media/c4b931b861f244166b7b86faff7aa842/hrefI plan on going into more detail about how to work with Quil but the premise is simple.

A setup function defines the initial state of your animation.

An update function modifies the state of your animation.

A draw function draws the new step or frame of your animation based on the state you set in update.

Clojure

Now, just take a moment and realize that all this was done by someone who has written next to no Clojure before. Yes, Clojure is quite difficult to read, which makes it scary to approach. But let me take a moment to lay some initial groundwork for you that may convince you to give Clojure a shot, if only to have some fun and play with Quil. All I ask you to do is force yourself to get past all those parenthesis. They really are not that big of a deal once you get used to Lisp’s crazy Polish Style Notation (+ 3 4 vs 3 + 4).

Leiningen

Leiningen is the first thing that you should download

🐚 brew install leiningen

Leiningen (lein) comes with some very basic commands that you can run to stand up the skeleton of a basic Clojure application and run it. Leiningen is, hands-down, the easiest way to get started with Clojure (outside of downloading some IDE like Light Table or emacs). Once you have leiningen up, create a new project.

Once you have leiningen up, create a new project.

🐚 lein new app clojure-app

That command will create a basic directory-structure and some files that you can start to fill with Clojure code. You can also include 3rd party Clojure libraries and Leiningen will detect and install them for you.

When you have something written, you just run your project using leiningen.

🐚 lein run

Checkout their Tutorial to find out more.

Clojure Docs

Clojure’s docs are likely some of the best that I have ever seen. The reason for that is because they are chock full of code examples that have been submitted, modified, and curated by the community.

Just take a look at the documentation for the reduce function. If only all languages had a doc website like this!

Try Clojure

Obviously, you may want to try out a little Clojure yourself before you start to download leiningen and create your first project. Welp, you could just run lein repl and immediately drop into a Clojure cli, but I think you should start by visiting one of the following websites:

Try Clojure

exercism

Pros and Cons

While Clojure is a ton of fun, it is not without its drawbacks. Here are a few things that I liked and a few that I did not.

Pros

Excellent Docs

Crazy fast

Familiar syntax for LISP people

Personable, able, passionate community

The repl (hot-update your code while it is running to see changes immediately)

Cons

Sparse choice of Rails-like frameworks. Clojure people love micro-frameworks and they like to have a lot of control over the structure of their projects.

Oddly-named functions. If you Google “Clojure Map” you will get results for the map function, not the {:a 1 :b 2} kind of map that you may be thinking about.

JVM. The JVM is a beast to start-up. But, once you understand how to use the REPL, that is no problem. However, even after a few weeks in Clojure, I found the REPL difficult to use.

My Conclusion

I probably won’t be writing a web API in Clojure anytime soon, but I love having a tool that does cool stuff outside the web world that is so easy to work within. Not everything needs to be for work, sometimes we just code for fun. And Clojure certainly is fun!
