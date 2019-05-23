select * from queryHistory where email='geoff@factor-50.co.uk' and boardName='My first dashboard'

/*
Explore query history further by adding more fields to your query.

cost - Cost of your query after any cost-savings via cache are applied.
savedCosts - How much $ saved as a result of using cache.
savedBytes - # of bytes that were saved as a result of using cache.
status - Whether your query executed (true) or had an error (false)
boardName - Name of the Board where the selected query is stored.
tabName - The name of the query tab your SQL is written in.
*/