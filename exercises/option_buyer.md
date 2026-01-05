
Market --> Oracle
    - current market price is P_{$/X}  = 99
buyer:
    - "I am bullish on X. X will surpass to $P = 108$, so I will lock in the right to buy at $K = 108$ , so I can profit the upcoming appreciation"

    - Let me query if there are any calls available with strike $P = 108$ --> getCalls(strike = 108)
    

        - What is the intrinsic value?" → For this OTM call: $\max(0, P_{spot} - K) = \max(0, 99 - 108) = 0$
        
        - "What is the time value?" → Since intrinsic = 0, entire premium is time value (also called extrinsic value)

          - What is the expiry $T$?
          - What is the implied volatility $\sigma_{imp}$?
          - What is the delta $\Delta$ (exposure per dollar of premium)?


How does the byuterpays the preium and ensures the access to the promise ?

This queries the option clearing house for all calls with strike 108, What information does the buyer needs to asses if the call is fairly priced.

What questions would he ask ?

- I am depositing a margin Y that entails me the maximum synthetic exposure to X for $R_X$
- Is the call margin usfficent for R_X for all calls at strike  strike = 108
- What is the premia of this option:
    
    - What is the time value of this option ?
    - What is the interinsic value of this option ?
This is the return object I am expecting to asses my risk 
