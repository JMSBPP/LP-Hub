
Market --> Oracle
    - current market price is P_{$/X}  = 99

buyer:
    - "I am bullish on X. X will surpass to $P = 108$, so I will lock in the right to buy at $K = 108$ , so I can profit the upcoming appreciation"

    - I am depositing a margin Y that entails me the maximum synthetic exposure to X for $R_X$

    --> As buyer I do deposit to the clearing firm R_Y, this Y must be
    
    margin = buy R_X at 108 +  highest premia I would ever pay if things do not go my way


    - Let me query if there are any calls available with strike $P = 108$ --> getCalls(strike = 108)
    

        - What is the intrinsic value?" → For this OTM call: $\max(0, P_{spot} - K) = \max(0, 99 - 108) = 0$
        
        - "What is the time value?" → Since intrinsic = 0, entire premium is time value (also called extrinsic value)

          - What is the expiry $T$?
          - What is the implied volatility $\sigma_{imp}$?
          - What is the delta $\Delta$ (exposure per dollar of premium)?


