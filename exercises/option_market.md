

The option market must display this

       85     90     95    100    105    110    115

Calls  14.05   9.35   5.50   2.70   1.15    .45    .20
Puts     .10    .45   1.55   3.70   7.10  11.35  16.10

A call at 95  means the call option seller is offering the right for the buyer to buy X at 95. Current market conditions are p = 99



(k,$\int \phi$)

Intrinsic value of the call is the opportunity cost of the seller of the call. He is loosing on selling at 99 now, for promising a sale at 95. Thus the option is ITM, the CLAMM economic equivalence to option order book is true only for OTM options. This is the LP  only sells OTM options at any strike



Let's have the case of the call option with strike 105. Then the call is OTM and option price is only time value


$$
\int \phi^E = "\text{time value}"
$$

This time value maps to the trading fee the buyer will pay for buying the option. This is we are querying the 

E[cumulative trading fees up to strike K]
- the constrain is that if the pool is hookless it must return a constant fee

- If it is not it must query a hookAdapter for the expected value if it implements dynamic fee

- Now to display this we must query the following 

"An OTM option exists at strike $𝐾$ iff there exists non-zero liquidity density on the interval immediately adjacent to K"

If there is no non-zero liquidity density on that interval we default to not showing that strike

THe first component to arquitecure is the liquidity density function. 

We need a predicate that says there is non-zero liquidity density over the current price to strike price interval.

market price --> tickCurrent
strike --> tickStrike


Internally we ask 
 - what is the tickSpacing of the pool

 Give me all ricks on the closed interval [tickCurrent, tickStrike] --> ricks[]

 query the liquidity density for all ricks[] -- liquidityOnInterval

 -  Is that liquidity non zero --> yes --> display
 (K)

we can query the liquidityOnInterval for all pools where X is present. 

However, let's narrow down to one pool (Assuming there is only one to query)
- X is paired with cash Y




