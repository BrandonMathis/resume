# Understand the Basics (SASS)

URL: https://medium.com/@brandonmathis/understand-the-basics-sass-59545dd40ccb
RSS publication date: Thu, 23 May 2019 15:23:57 GMT
Retrieved: 2026-11-04
Source: Medium RSS; plain-text derivative. Original HTML is preserved in `sources/web/research-5.json`. Embedded code may be links only. Original publication dates, when stated, appear below.

SASS & CSSThe other day I was watching a web-cast from Hubspot. The web-cast centered around a simple question “Can I use SASS on your blog theming platform.” The answer to me seemed obvious. Yes you can use SASS or LESS or any language to style your blog so long as it compiles down to css. But I was surprised when the Hubspot team answered “No.”

I understand the answer. NO you cannot upload SASS to Hubspot’s servers and have it work like a CSS file. This doesn’t have to stop you from being able to use SASS to style HTML anywhere, even on a platform like Hubspot.

Take a look at this snippet that defines a class named a section with a few modifier classes --sm, --med, --lg, --xl.

https://medium.com/media/6c6033a80efa354c391f8360bb636382/hrefIn this tiny snippet we’re doing several things that you can’t get done in vanilla css (not 100% true). We’re looping over a list containing the sizes we want [sm, med, lg, xl] and doing some math where we multiply a $base-spacing by a factor of the index of the size in the previously stated list.

You can turn this SASS into CSS using the SASS cli tool.

🐚 sass file.scss file.css

This gives you the following CSS.

https://medium.com/media/a40edafec5af58e6bdf19a7e18d66893/hrefTry uploading this to Hubspot’s blog theming platform. Now realize that you are now theming your Hubspot blog using SCSS. Easy! You could even further automate this with a --watch and perhapse a npm deploy command that FTPs your generate css file(s) up to Hubspot!
