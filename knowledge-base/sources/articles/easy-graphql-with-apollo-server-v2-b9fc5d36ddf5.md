# Easy GraphQL with Apollo Server v2

URL: https://medium.com/@brandonmathis/easy-graphql-with-apollo-server-v2-b9fc5d36ddf5
RSS publication date: Mon, 06 Jan 2020 22:03:20 GMT
Retrieved: 2026-11-04
Source: Medium RSS; plain-text derivative. Original HTML is preserved in `sources/web/research-5.json`. Embedded code may be links only. Original publication dates, when stated, appear below.

https://www.apollographql.com/REST has dominated the web API landscape for years now. It is simple to design and develop these APIs but not without a major cost. REST APIs are 100% opinionated and follow very loose conventions. Data served to clients can differ in structure for any reason. This may not be an issue for some but for those people struggling to create consistency within their API(s), I would encourage you to look at GraphQL.

GraphQL has been growing at a rapid pace over the past few years and many businesses are utilizing the GraphQL standard as the de-facto standard for their API. Github as even announced that v4 of their API will be 100% GraphQL and non-REST. So, if you are interested in seeing a trivial GraphQL implementation then I have one for you

GraphQL with Express Apollo Server v2

I find the simplest way to implement a GraphQL API is to use Apollo’s GraphQL-Server library that supports a multitude of HTTP platform/library integrations. For this example, I will be working in express and the completed code will be this.

https://medium.com/media/0ec19115f3d769b596e59093c05b8939/hrefIn this example we will define an API that returns a collection of Films and their subsequent directors. For the database, I am keeping things in a simple JS Object but you could use any data source (Mongo, SQL, or even some other API).

typeDefs (GraphQL Schema)

Our typeDefs are the heart and soul of GraphQL. It is where we will define all the types of resources accessible to clients of our API.

https://medium.com/media/8cfa82fcd6cdc22a9ad7486b60d03f50/hrefresolvers

Resolvers define how data is obtained when it is requested by a client.

https://medium.com/media/6433fd80c2f2b6fa1bf632b472d4c4ec/hrefConfig & Standup

The remainder of the code is simply a mix of express and apollo-server-graphql statup and configuration.

https://medium.com/media/23f867fce5a1a3c39e8bec007ef475b6/hrefGraphQL is making major progress and is seeing more and more use across the tech industry. If you are looking to build a simple API and avoid endless internal business discussions debating how your API should consume and present data, please consider giving GraphQL a try!
