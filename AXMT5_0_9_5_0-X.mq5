//+------------------------------------------------------------------+
//| Algo:      Alpha-X Premium System
//| CodeName:  Alpha-X Premium      
//| Team:      Taatu Ltd. (info@taatu.co)
//| Motto:     We are bad ass !!!!
//|
//| Date:      September 1, 2017
//|
//| Desc:      The objective of this strategy is to buy any instruments
//|            on margin. However, particular attention is focused on managing
//|            the margin and to maximize use of leverage.
//|
//| Experim:  
//|            September 11, 2017 - Convert the code from MQL4 to MQL5.
//|         
//|            September 18, 2017 - After backtesting and optimizing, we 
//|            realize that there is some risk associated wth recovery and 
//|            consolidation after a massive retracement. The risk has been 
//|            identified as an increase gap between the long composite index
//|            and the short entries of the Benchmark. In order to reduce the gap,
//|            we will implement protective hedge on selected individual 
//|            component of the composite index.
//|
//|            September 22, 2017 - Re-engineer completely the trading strategy 
//|            based on the backtest and experiment to even further reduce the risk 
//|            by implementing a max allowed positions.
//|
//|            September 23, 2017 - Implement dynamic lot size and dynamic 
//|            exposure based on market conditions. Implement function to 
//|            analyse and allocate adequate balance between short and long 
//|            trades to maximize market neutral strategy.
//|
//|            September 24, 2017 - Implement the testing function to avoid
//|            over-exposure on the short-side.
//|
//|            September 28, 2017 - Tested on random data to make sure the
//|            system do not overfit and is solely optimized on historical
//|            data.
//|
//|            November 6, 2017 - Implementation of a pseudo Neural Network
//|            Perceptron Model with various conditions such as candle pattern
//|            and tick volume. The system will analyse previous period of 
//|            1000 past candles on 15 min chart which is equivalent to about
//|            10 days. Based on the past price behavior, the system will 
//|            decide for the most probable trade to enter. The Neural Network
//|            decision system is now implemented for both FX and stocks.
//|            The idea of Alpha-X is to precisely enter profitable trades 
//|            regardless of the underlying instrument and purely on a 
//|            quantitative approach.
//|
//|            November 7, 2017 - Developing on top of the strategy, a 
//|            5 level grid a "pseudo" martingale system. Improve the candle
//|            pattern recognition model. 
//|
//|            November 11, 2017 - Validating Model with 99% quality historical
//|            data. from August 20, 2014 to August 30, 2014. Testing with lower
//|            quality historical data is not reflecting the actual performance.
//|            From that lesson learned, improvement can be made by identifying 
//|            the best entry level on the minute timeframe as well as support
//|            and resistance for a proper exit in case of SL.
//|
//|            November 10, 2017 - Backtest and adjusting pattern recognition
//|            function. Backtest from 25 June 2013, Issue with drawdown.
//|            
//|            November 22, 2017 - Removing Forex Arbitrage to focus only on stocks 
//|            for this system according to a decision we have made to 
//|            reorganise our activities and projects. FX will be implemented 
//|            specifically based on a system template independently.
//|
//|            March 7, 2018 - Correction of known bugs and optimization.
//|
//|            Note: The following system has been built on the previous 
//|            framework and may not contained all the standard functions.
//|
//|           ************************************************************
//|           Algo can be attached to any chart: settings are dynamic.
//|           ************************************************************
//|                                                                  
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017"
string version  =   "0.9.5.0-X";
string AlgoName =   "AX - Alpha-X (MT5)";
//+------------------------------------------------------------------+
//| LIBRARIES
//+------------------------------------------------------------------+
#include <tframework.mqh>
//+------------------------------------------------------------------+
//| CONFIGURABLE VARIABLES
//+------------------------------------------------------------------+
input string            ax_Separator_1="";//_____________________ SYSTEM SELECTION  _________________________
input bool              ax_Somchai_Millionaire=false;                //Be a Somchai, Be a Millionaire.
input double            ax_Risk_Level=4;                             //Risk Level, 1 to 10. Low to High.
input bool              ax_Enable_Equity_Trading = true;             //Enable Stocks Trading
input bool              ax_Enable_FX_Equity_Hedge = false;            //Enable FX/Equity Hedge
input string            ax_Separator_1_1="";                         //.
input string            ax_Separator_2="";//_____________________ TRADING ACTIVITY ___________________________
input int               ax_Market_OpenHour=18;                       //GMT time (US market open: 14:30, UK market open: 9:00) //XM: settings: 18 instead of 15;
input int               ax_Market_CloseHour=22;                      //GMT time (US market open: 21:00) //XM: 22 instead of 21;
input double            ax_EQ_TakeProfit_PCT=0.01;                     //Take Profit in percentage 0.01 = 1%.
input double            ax_EQ_Short_StopLoss_PCT= -0.20;             //Equity Short Stop Loss in percentage -0.01 = -1%.
input double            ax_EQ_Long_StopLoss_PCT = -0.20;             //Equity Long Stop Loss in percentage -0.01 = -1%.
input bool              ax_Debug_Mode=true;                         //Enable Debug Logging.
input string            ax_Benchmark_Symbol="US500Cash";             //Benchmark
input string            ax_FX_Equity_HedgingPair = "USDJPY";         //FX Pair for Equity Hedge
input string            ax_Separator_2_1="";                         //.
input string            ax_Separator_3="";//_____________________ PORTFOLIO COMPONENTS _______________________
input string            ax_Index_Component_1 = "Apple";              /*Instrument 01 */
input string            ax_Index_Component_2 = "Microsoft";          /*Instrument 02 */
input string            ax_Index_Component_3 = "J&J";                /*Instrument 03 */
input string            ax_Index_Component_4 = "ExxonMobil";         /*Instrument 04 */
input string            ax_Index_Component_5 = "Procter&Gam";        /*Instrument 05 */
input string            ax_Index_Component_6 = "WellsFargo";         /*Instrument 06 */
input string            ax_Index_Component_7 = "HomeDepot";          /*Instrument 07 */
input string            ax_Index_Component_8 = "Verizon";            /*Instrument 08 */
input string            ax_Index_Component_9 = "Coca-Cola";          /*Instrument 09 */
input string            ax_Index_Component_10 = "Merck&Co";          /*Instrument 10 */
input string            ax_Index_Component_11 = "Pepsico";           /*Instrument 11 */
input string            ax_Index_Component_12 = "Disney";            /*Instrument 12 */
input string            ax_Index_Component_13 = "Boeing";            /*Instrument 13 */
input string            ax_Index_Component_14 = "McDonalds";         /*Instrument 14 */
input string            ax_Index_Component_15 = "3MCo";              /*Instrument 15 */
input string            ax_Index_Component_16 = "IBM";               /*Instrument 16 */
input string            ax_Index_Component_17 = "Altria";            /*Instrument 17 */
input string            ax_Index_Component_18 = "WalMart";           /*Instrument 18 */
input string            ax_Index_Component_19 = "Facebook";          /*Instrument 19 */
input string            ax_Index_Component_20 = "JPMorgan";          /*Instrument 20 */
input string            ax_Separator_3_1="";//.
input string            ax_Separator_4="";//_____________________ ADVANCED ALGO SETTINGS _______________________
input bool              ax_Random_Walk_Theory = false;                //Enable Random Walk Theory Mode
input int               ax_Magic_ID_Model_Suffix = 5000;              //Magic ID (>1000, Round number)
input double            ax_NAV_Divider=100;                           //NAV Unit (Divide the portfolio into...) 
input double            ax_iMA_Distance_vs_MA_Median = 0.01;          //Distance Moving Average (MEDIAN)
input int               ax_FX_HedgeDirection = 1;                     //FX Pair Equity Hedge Direction
input double            ax_Equity_Max_Pct_StdDev_Rel_Bal = 0.2;       //Equity Maximum Standard Deviation (0.1 = 10%)
input double            ax_Equity_Ad_Additonal_Pos_At_DD = 0.2;       //Equity Add Additional Position while Drawdown exceed PCT (-0.1 = -10%)
input ENUM_TIMEFRAMES   ax_FX_Hedge_iMA_Period = PERIOD_D1;           //FX iMA Timeframe Period
input ENUM_TIMEFRAMES   ax_Equity_iMA_Period = PERIOD_D1;             //Equity iMA Timeframe Period
input int               ax_iMA_Period_Default = 200;                  //Default Moving Average Reference
input ENUM_TIMEFRAMES   ax_Equity_stdDev_Period = PERIOD_D1;          //Equity Standard Deviation Timeframe
input int               ax_stdDev_Period_Default = 300;               //Default Standard Deviation Period
//+------------------------------------------------------------------+
//| GENERIC VARIABLES
//+------------------------------------------------------------------+
double           CurrentAsk,CurrentBid;
int              OrderSlippage=1000;
//+------------------------------------------------------------------+
//| AX VARIABLES
//+------------------------------------------------------------------+
double           ax_Base_Account_Dollar_Amount=0;
int              ax_Number_Of_Components= 20;
int              ax_Magic_ID_Model_Long = ax_Magic_ID_Model_Suffix+1,
ax_Magic_ID_Model_Short=ax_Magic_ID_Model_Suffix+100,
ax_Magic_ID_Model_FX_Hedging=ax_Magic_ID_Model_Suffix+200;
string           ax_OrderCommentCode="_ax_CIndex_",ax_OrderCommentCode_FX_Hedging="ax_FX_Hedge_",ax_OrderCommentCode_FX_Arb="ax_FX_Arb_";
int              ax_Computed_Multiplier_Factor=1;
double           ax_Risk_Level_Set=ax_Risk_Level;
double           ax_Enable_Dynamic_Lot_Volume_Set=false;
double           ax_Reference_NAV=0;
double           ax_Target_NAV=0;
//+------------------------------------------------------------------+
//| AX ASSETS VARIABLES & ARRAYS
//+------------------------------------------------------------------+
double           ax_FX_Equity_HedgingPair_Dollar_Amount=0;
double           ax_Index_Component_Dollar_Amount_Array[];
double           ax_Benchmark_Performance_Period=0;
double           ax_Index_Component_PCT_Performance_Period_Array[];
double           ax_Index_Component_StdDev_Array[];
MqlRates         ax_Benchmark_HistData_Array[];
MqlRates         ax_Index_Component_1_HistData_Array[],ax_Index_Component_2_HistData_Array[],ax_Index_Component_3_HistData_Array[],ax_Index_Component_4_HistData_Array[],
ax_Index_Component_5_HistData_Array[],ax_Index_Component_6_HistData_Array[],ax_Index_Component_7_HistData_Array[],ax_Index_Component_8_HistData_Array[],
ax_Index_Component_9_HistData_Array[],ax_Index_Component_10_HistData_Array[],ax_Index_Component_11_HistData_Array[],ax_Index_Component_12_HistData_Array[],
ax_Index_Component_13_HistData_Array[],ax_Index_Component_14_HistData_Array[],ax_Index_Component_15_HistData_Array[],ax_Index_Component_16_HistData_Array[],
ax_Index_Component_17_HistData_Array[],ax_Index_Component_18_HistData_Array[],ax_Index_Component_19_HistData_Array[],ax_Index_Component_20_HistData_Array[];
string           ax_Index_Component_Sorted_Performance_Array[],ax_Index_Component[];
//+------------------------------------------------------------------+
//| Initialization function                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
//----
   ax_Init_System();
   tfk_add_instruments_watchlist();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Deinitialization function                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---- 
// We don't de-init, because we are badass !!!!
//----
  }
//+------------------------------------------------------------------+
//| Iteration function                                               |
//+------------------------------------------------------------------+
void OnTick()
  {
   ax_Start_System();
  }
//+------------------------------------------------------------------+
// Function:    Init() Initialise the system Code Name.
// Desc:        Initialise code Name system variables.        
//+------------------------------------------------------------------+
void ax_Init_System()
  {
   Print("*** System initialized...");
   Print("*** Lot size: Dynamically calculated.");
  }
//+------------------------------------------------------------------+
// Function:    Start() Start the system code name.
// Desc:        Start code name system           
//+------------------------------------------------------------------+
void ax_Start_System()
  {
   SetInterface(AlgoName,Company,version);
   ax_Init_Assets_Variables();
   ax_set_AUM_Base_Amount();
  
   if(Hour4()>=ax_Market_OpenHour && Hour4()<=ax_Market_CloseHour) {
     ax_EnterTradeOnCondition();
     ax_ExitTradeOnCondition(CurrentAsk);
   }
  }
//+------------------------------------------------------------------+
// Function:    Set System mode according to risk settings
// Return:      No value returned.
// Parameters:  No parameter.
// Desc:        This function set the risk settings to match the
//              selected mode.
//+------------------------------------------------------------------+
void ax_Set_System_Mode_Risk_Level()
  {
   if(ax_Somchai_Millionaire)
     {
      ax_Enable_Dynamic_Lot_Volume_Set=true;
      ax_Risk_Level_Set=10;
     }
  }
//+------------------------------------------------------------------+
// Function:    Calculate seed Asset Under Management.
// Return:      No value returned.
// Parameters:  No parameters.
// Desc:        This function get the initial balance for different 
//              calculation such as the volume lot size and number 
//              of positions.
//+------------------------------------------------------------------+
void ax_set_AUM_Base_Amount()
  {
   double Base_Amount=0;
   if(AccountInfoDouble(ACCOUNT_EQUITY)<1000) Base_Amount=1000; else Base_Amount=AccountInfoDouble(ACCOUNT_EQUITY);
   if(ax_Base_Account_Dollar_Amount==0)
     {
      if(ax_Risk_Level<=4) ax_Base_Account_Dollar_Amount=(Base_Amount*2);
      if(ax_Risk_Level>4) ax_Base_Account_Dollar_Amount=Base_Amount;
     }

   ObjectCreate4("ObjMagicIDClient",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjMagicIDClient","Ref. base AUM: "+IntegerToString((int)(ax_Base_Account_Dollar_Amount))+" Risk Level:"+IntegerToString((int)ax_Risk_Level),10,"Verdana",White);
   ObjectSet4("ObjMagicIDClient",OBJPROP_CORNER,0);
   ObjectSet4("ObjMagicIDClient",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjMagicIDClient",OBJPROP_YDISTANCE,220);
  }
//+------------------------------------------------------------------+
// Function:    Get information specific to an instrument
// Return:      Latest Price is returned.
// Parameters:  Psymbol as the instrument to extract.
//              PwhatInfo = "price", "contractSize", "dollarAmount"
// Desc:        This function return the latest price of an instrument.
//+------------------------------------------------------------------+
double ax_get_Symbol_Info(string Psymbol,string PwhatInfo)
  {
   double returned_Value=0;
   MqlTick latest_price;
   double cPrice,cContractSize,cMinLotSize;
   cPrice=SymbolInfoDouble(Psymbol,SYMBOL_ASK);
   cContractSize=SymbolInfoDouble(Psymbol,SYMBOL_TRADE_CONTRACT_SIZE);
   cMinLotSize=SymbolInfoDouble(Psymbol,SYMBOL_VOLUME_MIN);
   if(PwhatInfo == "minLotSize") returned_Value = cMinLotSize;
   if(PwhatInfo == "price") returned_Value = cPrice;
   if(PwhatInfo == "contractSize") returned_Value = cContractSize;
   if(PwhatInfo == "dollarAmount") returned_Value = cPrice * cContractSize * cMinLotSize;
   if(PwhatInfo=="stdDev"){ if(cPrice>0) returned_Value=ax_ComputeTechIndicators(Psymbol,"iStdDev",ax_Equity_stdDev_Period,ax_stdDev_Period_Default,0)/cPrice; else returned_Value=1; }
   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Initialize Index Component Array By Performance
// Return:      Return the size of the array.
// Parameters:  No Parameters.
// Desc:        This function initialize arrays and build its initial
//              content for the composite equity index.
//+------------------------------------------------------------------+
int ax_Build_Array_Of_Index_Component()
  {
   ENUM_TIMEFRAMES Period=ax_Equity_iMA_Period;
   int NumPeriod=500,array_Min_Size=9999;
   int Array_Size=ax_Number_Of_Components+1;
   ArrayResize(ax_Index_Component_Sorted_Performance_Array,Array_Size,Array_Size);
   ArrayResize(ax_Index_Component_Dollar_Amount_Array,Array_Size,Array_Size);
   ArrayResize(ax_Index_Component_PCT_Performance_Period_Array,Array_Size,Array_Size);
   ArrayResize(ax_Index_Component,Array_Size,Array_Size);
   ArrayResize(ax_Index_Component_StdDev_Array,Array_Size,Array_Size);
//Extract Historical rates
   ArraySetAsSeries(ax_Benchmark_HistData_Array,true); int b=CopyRates(ax_Benchmark_Symbol,Period,0,NumPeriod,ax_Benchmark_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_1_HistData_Array,true); int i_1 = CopyRates(ax_Index_Component_1,Period,0,NumPeriod,ax_Index_Component_1_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_2_HistData_Array,true); int i_2 = CopyRates(ax_Index_Component_2,Period,0,NumPeriod,ax_Index_Component_2_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_3_HistData_Array,true); int i_3 = CopyRates(ax_Index_Component_3,Period,0,NumPeriod,ax_Index_Component_3_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_4_HistData_Array,true); int i_4 = CopyRates(ax_Index_Component_4,Period,0,NumPeriod,ax_Index_Component_4_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_5_HistData_Array,true); int i_5 = CopyRates(ax_Index_Component_5,Period,0,NumPeriod,ax_Index_Component_5_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_6_HistData_Array,true); int i_6 = CopyRates(ax_Index_Component_6,Period,0,NumPeriod,ax_Index_Component_6_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_7_HistData_Array,true); int i_7 = CopyRates(ax_Index_Component_7,Period,0,NumPeriod,ax_Index_Component_7_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_8_HistData_Array,true); int i_8 = CopyRates(ax_Index_Component_8,Period,0,NumPeriod,ax_Index_Component_8_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_9_HistData_Array,true); int i_9 = CopyRates(ax_Index_Component_9,Period,0,NumPeriod,ax_Index_Component_9_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_10_HistData_Array,true); int i_10 = CopyRates(ax_Index_Component_10,Period,0,NumPeriod,ax_Index_Component_10_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_11_HistData_Array,true); int i_11 = CopyRates(ax_Index_Component_11,Period,0,NumPeriod,ax_Index_Component_11_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_12_HistData_Array,true); int i_12 = CopyRates(ax_Index_Component_12,Period,0,NumPeriod,ax_Index_Component_12_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_13_HistData_Array,true); int i_13 = CopyRates(ax_Index_Component_13,Period,0,NumPeriod,ax_Index_Component_13_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_14_HistData_Array,true); int i_14 = CopyRates(ax_Index_Component_14,Period,0,NumPeriod,ax_Index_Component_14_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_15_HistData_Array,true); int i_15 = CopyRates(ax_Index_Component_15,Period,0,NumPeriod,ax_Index_Component_15_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_16_HistData_Array,true); int i_16 = CopyRates(ax_Index_Component_16,Period,0,NumPeriod,ax_Index_Component_16_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_17_HistData_Array,true); int i_17 = CopyRates(ax_Index_Component_17,Period,0,NumPeriod,ax_Index_Component_17_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_18_HistData_Array,true); int i_18 = CopyRates(ax_Index_Component_18,Period,0,NumPeriod,ax_Index_Component_18_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_19_HistData_Array,true); int i_19 = CopyRates(ax_Index_Component_19,Period,0,NumPeriod,ax_Index_Component_19_HistData_Array);
   ArraySetAsSeries(ax_Index_Component_20_HistData_Array,true); int i_20 = CopyRates(ax_Index_Component_20,Period,0,NumPeriod,ax_Index_Component_20_HistData_Array);
//Get the smallest array
   if(array_Min_Size>b) { if(b!=-1) array_Min_Size=b;} if(array_Min_Size>i_1) { if(i_1!=-1) array_Min_Size=i_1;} if(array_Min_Size>i_2) { if(i_2!=-1) array_Min_Size=i_2;}
   if(array_Min_Size>i_3) { if(i_3!=-1) array_Min_Size = i_3;} if(array_Min_Size>i_4) { if(i_4!=-1) array_Min_Size = i_4;} if(array_Min_Size>i_5) { if(i_5!=-1) array_Min_Size = i_5;}
   if(array_Min_Size>i_6) { if(i_6!=-1) array_Min_Size = i_6;} if(array_Min_Size>i_7) { if(i_7!=-1) array_Min_Size = i_7;} if(array_Min_Size>i_8) { if(i_8!=-1) array_Min_Size = i_8;}
   if(array_Min_Size>i_9) { if(i_9!=-1) array_Min_Size = i_9;} if(array_Min_Size>i_10) { if(i_10!=-1) array_Min_Size = i_10;} if(array_Min_Size>i_11) { if(i_11!=-1) array_Min_Size = i_11;}
   if(array_Min_Size>i_12) { if(i_12!=-1) array_Min_Size = i_12;} if(array_Min_Size>i_13) { if(i_13!=-1) array_Min_Size = i_13;} if(array_Min_Size>i_14) { if(i_14!=-1) array_Min_Size = i_14;}
   if(array_Min_Size>i_15) { if(i_15!=-1) array_Min_Size = i_15;} if(array_Min_Size>i_16) { if(i_16!=-1) array_Min_Size = i_16;} if(array_Min_Size>i_17) { if(i_17!=-1) array_Min_Size = i_17;}
   if(array_Min_Size>i_18) { if(i_18!=-1) array_Min_Size = i_18;} if(array_Min_Size>i_19) { if(i_19!=-1) array_Min_Size = i_19;} if(array_Min_Size>i_20) { if(i_20!=-1) array_Min_Size = i_20;}
   array_Min_Size=array_Min_Size -1;
//Calculte Performance ***
   if(b!=-1) ax_Benchmark_Performance_Period=(ax_Benchmark_HistData_Array[1].close/ax_Benchmark_HistData_Array[array_Min_Size].close)-1; else ax_Benchmark_Performance_Period=-1;
   if(i_1!=-1) ax_Index_Component_PCT_Performance_Period_Array[1] = (ax_Index_Component_1_HistData_Array[1].close/ax_Index_Component_1_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[1] = -1;
   if(i_2!=-1) ax_Index_Component_PCT_Performance_Period_Array[2] = (ax_Index_Component_2_HistData_Array[1].close/ax_Index_Component_2_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[2] = -1;
   if(i_3!=-1) ax_Index_Component_PCT_Performance_Period_Array[3] = (ax_Index_Component_3_HistData_Array[1].close/ax_Index_Component_3_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[3] = -1;
   if(i_4!=-1) ax_Index_Component_PCT_Performance_Period_Array[4] = (ax_Index_Component_4_HistData_Array[1].close/ax_Index_Component_4_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[4] = -1;
   if(i_5!=-1) ax_Index_Component_PCT_Performance_Period_Array[5] = (ax_Index_Component_5_HistData_Array[1].close/ax_Index_Component_5_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[5] = -1;
   if(i_6!=-1) ax_Index_Component_PCT_Performance_Period_Array[6] = (ax_Index_Component_6_HistData_Array[1].close/ax_Index_Component_6_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[6] = -1;
   if(i_7!=-1) ax_Index_Component_PCT_Performance_Period_Array[7] = (ax_Index_Component_7_HistData_Array[1].close/ax_Index_Component_7_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[7] = -1;
   if(i_8!=-1) ax_Index_Component_PCT_Performance_Period_Array[8] = (ax_Index_Component_8_HistData_Array[1].close/ax_Index_Component_8_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[8] = -1;
   if(i_9!=-1) ax_Index_Component_PCT_Performance_Period_Array[9] = (ax_Index_Component_9_HistData_Array[1].close/ax_Index_Component_9_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[9] = -1;
   if(i_10!=-1) ax_Index_Component_PCT_Performance_Period_Array[10] = (ax_Index_Component_10_HistData_Array[1].close/ax_Index_Component_10_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[10] = -1;
   if(i_11!=-1) ax_Index_Component_PCT_Performance_Period_Array[11] = (ax_Index_Component_11_HistData_Array[1].close/ax_Index_Component_11_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[11] = -1;
   if(i_12!=-1) ax_Index_Component_PCT_Performance_Period_Array[12] = (ax_Index_Component_12_HistData_Array[1].close/ax_Index_Component_12_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[12] = -1;
   if(i_13!=-1) ax_Index_Component_PCT_Performance_Period_Array[13] = (ax_Index_Component_13_HistData_Array[1].close/ax_Index_Component_13_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[13] = -1;
   if(i_14!=-1) ax_Index_Component_PCT_Performance_Period_Array[14] = (ax_Index_Component_14_HistData_Array[1].close/ax_Index_Component_14_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[14] = -1;
   if(i_15!=-1) ax_Index_Component_PCT_Performance_Period_Array[15] = (ax_Index_Component_15_HistData_Array[1].close/ax_Index_Component_15_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[15] = -1;
   if(i_16!=-1) ax_Index_Component_PCT_Performance_Period_Array[16] = (ax_Index_Component_16_HistData_Array[1].close/ax_Index_Component_16_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[16] = -1;
   if(i_17!=-1) ax_Index_Component_PCT_Performance_Period_Array[17] = (ax_Index_Component_17_HistData_Array[1].close/ax_Index_Component_17_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[17] = -1;
   if(i_18!=-1) ax_Index_Component_PCT_Performance_Period_Array[18] = (ax_Index_Component_18_HistData_Array[1].close/ax_Index_Component_18_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[18] = -1;
   if(i_19!=-1) ax_Index_Component_PCT_Performance_Period_Array[19] = (ax_Index_Component_19_HistData_Array[1].close/ax_Index_Component_19_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[19] = -1;
   if(i_20!=-1) ax_Index_Component_PCT_Performance_Period_Array[20] = (ax_Index_Component_20_HistData_Array[1].close/ax_Index_Component_20_HistData_Array[array_Min_Size].close)-1; else ax_Index_Component_PCT_Performance_Period_Array[20] = -1;

   return(Array_Size);
  }
//+------------------------------------------------------------------+
// Function:    Sort the content of the performance array of the
//              composite index.
// Return:      ParraySize = Size of the array.
// Parameters:  No Parameters.
// Desc:        This function sort the performance score of the 
//              composite index array.
//+------------------------------------------------------------------+
void ax_Sort_Index_Component_Performance_Array(int ParraySize)
  {
//Sort Component based on Performance.      
   int Array_Size=ParraySize;
   double done_pct=-1;

   int selected_index=-1;
   for(int i=1; i<=ax_Number_Of_Components; i++)
     {
      ax_Index_Component_Sorted_Performance_Array[i]="";
      selected_index=1;
      for(int j=1; j<=ax_Number_Of_Components-1; j++)
        {
         if(j<=Array_Size)
           {
            if(ax_Index_Component_PCT_Performance_Period_Array[selected_index]<ax_Index_Component_PCT_Performance_Period_Array[j+1]) selected_index=j+1;
           }
        }
      switch(selected_index)
        {
         case 1: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_1; break;
         case 2: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_2; break;
         case 3: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_3; break;
         case 4: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_4; break;
         case 5: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_5; break;
         case 6: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_6; break;
         case 7: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_7; break;
         case 8: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_8; break;
         case 9: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_9; break;
         case 10: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_10; break;
         case 11: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_11; break;
         case 12: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_12; break;
         case 13: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_13; break;
         case 14: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_14; break;
         case 15: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_15; break;
         case 16: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_16; break;
         case 17: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_17; break;
         case 18: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_18; break;
         case 19: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_19; break;
         case 20: ax_Index_Component_Sorted_Performance_Array[i] = ax_Index_Component_20; break;
        }
      ax_Index_Component_PCT_Performance_Period_Array[selected_index]=done_pct;
     }
  }
//+------------------------------------------------------------------+
// Function:    Compute the Index Component Array Standard Deviation
//              of each instrument.
// Return:      No value returned.
// Parameters:  No Parameters.
// Desc:        This function compute the standard deviation for 
//              each instrument in the array.
//+------------------------------------------------------------------+
void ax_Compute_Index_Component_Array_StdDev()
  {
//Calculate the Standard deviation in percentage ***
   for(int i=1; i<=ax_Number_Of_Components; i++)
     {
      string Index_Component_X;
      switch(i)
        {
         case 1: Index_Component_X = ax_Index_Component_1; break;
         case 2: Index_Component_X = ax_Index_Component_2; break;
         case 3: Index_Component_X = ax_Index_Component_3; break;
         case 4: Index_Component_X = ax_Index_Component_4; break;
         case 5: Index_Component_X = ax_Index_Component_5; break;
         case 6: Index_Component_X = ax_Index_Component_6; break;
         case 7: Index_Component_X = ax_Index_Component_7; break;
         case 8: Index_Component_X = ax_Index_Component_8; break;
         case 9: Index_Component_X = ax_Index_Component_9; break;
         case 10: Index_Component_X = ax_Index_Component_10; break;
         case 11: Index_Component_X = ax_Index_Component_11; break;
         case 12: Index_Component_X = ax_Index_Component_12; break;
         case 13: Index_Component_X = ax_Index_Component_13; break;
         case 14: Index_Component_X = ax_Index_Component_14; break;
         case 15: Index_Component_X = ax_Index_Component_15; break;
         case 16: Index_Component_X = ax_Index_Component_16; break;
         case 17: Index_Component_X = ax_Index_Component_17; break;
         case 18: Index_Component_X = ax_Index_Component_18; break;
         case 19: Index_Component_X = ax_Index_Component_19; break;
         case 20: Index_Component_X = ax_Index_Component_20; break;
        }
      ax_Index_Component_StdDev_Array[i]=ax_get_Symbol_Info(Index_Component_X,"stdDev");
     }
  }
//+------------------------------------------------------------------+
// Function:    Compute the Index Component Array the dollar amount
//              of each instrument.
// Return:      No value returned.
// Parameters:  No Parameters.
// Desc:        This function compute the dollar amount for each 
//              instrument in the array.
//+------------------------------------------------------------------+
void ax_Compute_Index_Component_Array_Dollar_Amount()
  {
//Calculate Dollar Amount ***
   ax_FX_Equity_HedgingPair_Dollar_Amount=ax_get_Symbol_Info(ax_FX_Equity_HedgingPair,"dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[1] = ax_get_Symbol_Info(ax_Index_Component_1, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[2] = ax_get_Symbol_Info(ax_Index_Component_2, "dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[3] = ax_get_Symbol_Info(ax_Index_Component_3, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[4] = ax_get_Symbol_Info(ax_Index_Component_4, "dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[5] = ax_get_Symbol_Info(ax_Index_Component_5, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[6] = ax_get_Symbol_Info(ax_Index_Component_6, "dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[7] = ax_get_Symbol_Info(ax_Index_Component_7, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[8] = ax_get_Symbol_Info(ax_Index_Component_8, "dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[9] = ax_get_Symbol_Info(ax_Index_Component_9, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[10] = ax_get_Symbol_Info(ax_Index_Component_10, "dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[11] = ax_get_Symbol_Info(ax_Index_Component_11, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[12] = ax_get_Symbol_Info(ax_Index_Component_12, "dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[13] = ax_get_Symbol_Info(ax_Index_Component_13, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[14] = ax_get_Symbol_Info(ax_Index_Component_14, "dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[15] = ax_get_Symbol_Info(ax_Index_Component_15, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[16] = ax_get_Symbol_Info(ax_Index_Component_16, "dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[17] = ax_get_Symbol_Info(ax_Index_Component_17, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[18] = ax_get_Symbol_Info(ax_Index_Component_18, "dollarAmount");
   ax_Index_Component_Dollar_Amount_Array[19] = ax_get_Symbol_Info(ax_Index_Component_19, "dollarAmount"); ax_Index_Component_Dollar_Amount_Array[20] = ax_get_Symbol_Info(ax_Index_Component_20, "dollarAmount");
  }
//+------------------------------------------------------------------+
// Function:    Compute the Index Component Array the dollar amount
//              of each instrument.
// Return:      No value returned.
// Parameters:  No Parameters.
// Desc:        This function compute the dollar amount for each 
//              instrument in the array.
//+------------------------------------------------------------------+
void ax_Filter_Index_Component_Array_With_Valid_Instrument()
  {
   double Account_Instrument_Max_Exposure=AccountInfoDouble(ACCOUNT_BALANCE)*ax_Equity_Max_Pct_StdDev_Rel_Bal;
   for(int i=0; i<=ax_Number_Of_Components; i++)
     {
      ax_Index_Component[i]="";
      int selected_Index=0;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_1) selected_Index = 1; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_2) selected_Index = 2;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_3) selected_Index = 3; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_4) selected_Index = 4;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_5) selected_Index = 5; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_6) selected_Index = 6;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_7) selected_Index = 7; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_8) selected_Index = 8;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_9) selected_Index = 9; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_10) selected_Index = 10;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_11) selected_Index = 11; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_12) selected_Index = 12;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_13) selected_Index = 13; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_14) selected_Index = 14;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_15) selected_Index = 15; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_16) selected_Index = 16;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_17) selected_Index = 17; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_18) selected_Index = 18;
      if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_19) selected_Index = 19; if(ax_Index_Component_Sorted_Performance_Array[i]==ax_Index_Component_20) selected_Index = 20;

      if(ax_Index_Component_Dollar_Amount_Array[selected_Index]*ax_Index_Component_StdDev_Array[selected_Index]<=Account_Instrument_Max_Exposure) ax_Index_Component[i]=ax_Index_Component_Sorted_Performance_Array[i];
     }
  }
//+------------------------------------------------------------------+
// Function:    Initialize Assets Variables
// Return:      No value returned.
// Parameters:  No Parameters.
// Desc:        This function compute all declared Assets Variables
//+------------------------------------------------------------------+
void ax_Init_Assets_Variables()
  {
   int Array_Size=ax_Build_Array_Of_Index_Component();
   ax_Compute_Index_Component_Array_Dollar_Amount();
   ax_Compute_Index_Component_Array_StdDev();
   ax_Sort_Index_Component_Performance_Array(Array_Size);
   ax_Filter_Index_Component_Array_With_Valid_Instrument();
   ax_Get_Average_Risk_Exposure();
  }
//+------------------------------------------------------------------+
// Function:    Compute the average risk exposure of the selection.
// Return:      Return false if exceed the available balance.
// Parameters:  No Parameters.
// Desc:        This function compute the average risk exposure
//              according to the selection of instruments and the 
//              available balance. Return false if excceed.
//+------------------------------------------------------------------+
bool ax_Get_Average_Risk_Exposure()
  {
   double Account_Max_Risk= AccountInfoDouble(ACCOUNT_BALANCE)*2;
   double Collected_Total = 0,Average_Risk_Amount = 0;
   bool returned_Value=true;

   for(int i=0; i<=ax_Number_Of_Components; i++)
      Collected_Total=Collected_Total+(ax_Index_Component_Dollar_Amount_Array[i]/2);
   Average_Risk_Amount=(((Collected_Total)/ax_Number_Of_Components)*ax_Risk_Level_Set);

   ObjectCreate4("ObjAvgRisk",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjAvgRisk","Average Required Margin ($): "+IntegerToString((int)(Average_Risk_Amount)),10,"Verdana",White);
   ObjectSet4("ObjAvgRisk",OBJPROP_CORNER,0);
   ObjectSet4("ObjAvgRisk",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjAvgRisk",OBJPROP_YDISTANCE,300);

   if(Average_Risk_Amount>Account_Max_Risk) returned_Value=false; else returned_Value=true;
   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Compute the NAV and return the value.
// Return:      Return the Net Asset Value.
// Parameters:  No Parameters.
// Desc:        This function compute the Net Asset Value.
//+------------------------------------------------------------------+
double ax_Get_Net_Asset_Value()
  {
   int TotalHistory=HistoryDealsTotal();
   ENUM_DEAL_TYPE HistoryType=0;
   double History_Amount_Operation=0,History_Deposit=0,History_Initial_Deposit=0,History_Withdrawal=0;
   double Net_Asset_Value=0,History_Equity=AccountInfoDouble(ACCOUNT_EQUITY);

   for(int i=0; i<=TotalHistory; i++)
     {
      HistoryDealGetTicket(i);
      HistoryDealSelect(HistoryDealGetTicket(i));
      HistoryType=(ENUM_DEAL_TYPE)(HistoryDealGetInteger(HistoryDealGetTicket(i),DEAL_TYPE));
      History_Amount_Operation=HistoryDealGetDouble(HistoryDealGetTicket(i),DEAL_PROFIT);

      if(HistoryType==DEAL_TYPE_BALANCE || HistoryType==DEAL_TYPE_BONUS ||
         HistoryType==DEAL_TYPE_CREDIT || HistoryType)
        {
         if(i==0)
            History_Initial_Deposit=History_Amount_Operation;
         else
           {
            if(History_Amount_Operation<0) History_Withdrawal=History_Withdrawal+History_Amount_Operation;
            if(History_Amount_Operation>0) History_Deposit=History_Deposit+History_Amount_Operation;
           }
        }
     }
   Net_Asset_Value=NormalizeDouble((((History_Equity-(History_Deposit-History_Initial_Deposit))-History_Withdrawal)/ax_NAV_Divider),2);

   ObjectCreate4("ObjNAV",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjNAV","Net Asset Value(NAV): "+DoubleToString(Net_Asset_Value),10,"Verdana",White);
   ObjectSet4("ObjNAV",OBJPROP_CORNER,0);
   ObjectSet4("ObjNAV",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjNAV",OBJPROP_YDISTANCE,260);

   return(Net_Asset_Value);
  }
//+------------------------------------------------------------------+
// Function:    Compute the ask or bid price of the composite index.
// Return:      Return Ask or Bid price.
// Parameters:  PBidPrice = false = return Ask, true = return Bid.
// Desc:        This function compute the bid or ask price of the 
//              composite index. If PBidPrice is set to true then 
//              return Bid else Ask price.
//+------------------------------------------------------------------+
double ax_Compute_Composite_Index_Price(bool PBidPrice)
  {
   double composite_Index_Value=0;
   int TotalOrders=PositionsTotal();
   string Index_Component_X;
   double Index_Component_X_LotSize=0,Index_Component_X_LotPUnit=0;
   double Index_Component_X_Price=0;
   ENUM_POSITION_TYPE Index_Component_X_OrderType=0;
   double Index_Computed_Value=0;
   long selected_Magic=0;

   for(int i=0; i<=TotalOrders; i++)
     {
      PositionGetTicket(i);
      Index_Component_X=PositionGetString(POSITION_SYMBOL);
      Index_Component_X_LotPUnit= SymbolInfoDouble(Index_Component_X,SYMBOL_TRADE_CONTRACT_SIZE);
      Index_Component_X_LotSize = PositionGetDouble(POSITION_VOLUME);
      Index_Component_X_Price=PositionGetDouble(POSITION_PRICE_CURRENT);
      Index_Component_X_OrderType=(ENUM_POSITION_TYPE)(PositionGetInteger(POSITION_TYPE));
      selected_Magic=PositionGetInteger(POSITION_MAGIC);
      if(selected_Magic==ax_Magic_ID_Model_Long || selected_Magic==ax_Magic_ID_Model_Short)
        {
         Index_Computed_Value=(Index_Component_X_Price*Index_Component_X_LotSize*Index_Component_X_LotPUnit*ax_getLotSizeMultiplier(ax_Enable_Dynamic_Lot_Volume_Set));
         if(Index_Component_X_OrderType==0)
            composite_Index_Value=composite_Index_Value+Index_Computed_Value; else composite_Index_Value=composite_Index_Value-Index_Computed_Value;
        }
     }

   ObjectCreate4("ObjCompIndexP",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjCompIndexP","Composite Index ($): "+DoubleToString(NormalizeDouble(composite_Index_Value,2)),10,"Verdana",White);
   ObjectSet4("ObjCompIndexP",OBJPROP_CORNER,0);
   ObjectSet4("ObjCompIndexP",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjCompIndexP",OBJPROP_YDISTANCE,280);

   return( NormalizeDouble(composite_Index_Value,2) );

  }
//+------------------------------------------------------------------+
// Function:    Compute the lot size multiplier.
// Return:      Return lot size multiplier.
// Parameters:  PenableDynAlloc = is to enable dynamic allocation.
//              if yes, then it will return the multiplier else return 1.
// Desc:        This function compute the lot size multiplier.
//+------------------------------------------------------------------+
int ax_getLotSizeMultiplier(bool PenableDynAlloc)
  {
   int TotalPos=PositionsTotal();
   int returned_Value=1;
   double Account_Equity=1;
   if(ax_Somchai_Millionaire)  Account_Equity = (AccountInfoDouble(ACCOUNT_EQUITY)*1.5);
   if(!ax_Somchai_Millionaire) Account_Equity = AccountInfoDouble(ACCOUNT_EQUITY);

   if(PenableDynAlloc) returned_Value = (int)(Account_Equity / (ax_Base_Account_Dollar_Amount*2) );
   if(returned_Value<1) returned_Value=1;

   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Compute the stop loss price based on multiplier
// Return:      Return the stop loss dollar amount
// Parameters:  PenableDynAlloc = is to enable dynamic allocation.
//              PlotVolume = is the volume of lot size from the selected trade.
//              if yes, then it will return the multiplier else return 1.
// Desc:        This function compute the stop loss price in dollar
//              amount.
//+------------------------------------------------------------------+
double ax_getStopLossDollarAmount(string Psymbol,bool PenableDynAlloc,double PlotVolume,int PorderType)
  {
   MqlTick latest_price;
   SymbolInfoTick(Psymbol,latest_price);
   double Stop_Loss_PCT=1;
   if(PorderType==0) Stop_Loss_PCT=ax_EQ_Long_StopLoss_PCT; else Stop_Loss_PCT=ax_EQ_Short_StopLoss_PCT;
   double SymbolContractSize=SymbolInfoDouble(Psymbol,SYMBOL_TRADE_CONTRACT_SIZE);
   double returned_Value=latest_price.ask*Stop_Loss_PCT*SymbolContractSize*PlotVolume;
   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Compute the dynamic target price based on multiplier
// Return:      Return the target amount
// Parameters:  PenableDynAlloc = is to enable dynamic allocation.
//              PlotVolume = is the volume of lot size from the selected trade.
//              if yes, then it will return the multiplier else return 1.
// Desc:        This function compute the dynamic target price in dollar
//              amount.
//+------------------------------------------------------------------+
double ax_getTargetDollarAmount(string Psymbol,bool PenableDynAlloc,double PlotVolume)
  {
   MqlTick latest_price;
   SymbolInfoTick(Psymbol,latest_price);
   double SymbolContractSize=SymbolInfoDouble(Psymbol,SYMBOL_TRADE_CONTRACT_SIZE);
   double returned_Value=latest_price.ask*ax_EQ_TakeProfit_PCT*SymbolContractSize*PlotVolume;
   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Compute technical indicators by updating global variables
// Return:      Return value of the selected indicator based Pindicator.
// Parameters:  PSymbol = Symbol of the instrument to extract information.
//              Pindicator = if = iRSIm iMA return respective indicator.
//              Pindex = Default one is 0. Set the value index to return.
// Desc:        This function compute indicators based on provided 
//              parameters.
//+------------------------------------------------------------------+
double ax_ComputeTechIndicators(string PSymbol,string Pindicator,ENUM_TIMEFRAMES Pperiod,int PIndic_Period,int Pindex)
  {
   int indicator_Handle=-1;
   double indicator_Value[];

   if(Pindicator=="iRSI")
     {
      indicator_Handle=iRSI(
                            PSymbol,               // symbol
                            Pperiod,               // timeframe
                            PIndic_Period,         // period
                            PRICE_CLOSE
                            );
     }
   if(Pindicator=="iMA")
     {
      indicator_Handle=iMA(
                           PSymbol,                // symbol
                           Pperiod,                // timeframe
                           PIndic_Period,          // MA averaging period
                           0,                      // MA shift
                           MODE_EMA,               // averaging method
                           PRICE_CLOSE
                           );
     }
   if(Pindicator=="iStdDev")
     {
      indicator_Handle=iStdDev(
                               PSymbol,            // symbol name 
                               Pperiod,            // period 
                               PIndic_Period,      // averaging period 
                               0,                  // horizontal shift 
                               MODE_EMA,           // smoothing type 
                               PRICE_CLOSE         // type of price or handle 
                               );
     }
   if(Pindicator=="iBands")
     {
      indicator_Handle=iBands(
                              PSymbol,             // symbol name 
                              Pperiod,             // period 
                              PIndic_Period,       // period for average line calculation 
                              0,                   // horizontal shift of the indicator 
                              2,                   // number of standard deviations 
                              PRICE_CLOSE          // type of price or handle 
                              );
     }

   CopyBuffer(indicator_Handle,Pindex,0,3,indicator_Value);
   return(indicator_Value[0]);
  }
//+------------------------------------------------------------------+
// Function:    Get the distance from the moving average in percentage.
// Return:      return the percentage distance from moving average 
//              return 0.01 = 1%, return -0.1 = -10%...
// Parameters:  Psymbol = instrument to look for. Pperiod = Timeframe
//              Pindic_Period = period of the indicator MA200, MA100...
// Desc:        This function locate the distance from the current price
//              and the moving average. Value is returned in percentage
//            
//+------------------------------------------------------------------+
double ax_getDistanceInPct_iMA(string Psymbol,ENUM_TIMEFRAMES Pperiod,int Pindic_Period)
  {
   MqlTick latest_price;
   double MA_Value=ax_ComputeTechIndicators(Psymbol,"iMA",Pperiod,ax_iMA_Period_Default,0);
   SymbolInfoTick(Psymbol,latest_price);
   return( (latest_price.ask/MA_Value)-1);
  }
//+------------------------------------------------------------------+
// Function:    Exit long side trades on condition met.
// Return:      No value returned.
// Parameters:  PcurrentAsk is the current composite index price.
//              PforceClose is to close all positions regardless conditions.
// Desc:        Exit long side trades based on condition fullfilled.
//            
//+------------------------------------------------------------------+
void ax_ExitLongTrade()
  {
   if(Hour4()>=ax_Market_OpenHour && Hour4()<=ax_Market_CloseHour)
     {
      bool PS;
      long OrderMagicNumber;

      //Trade only on Monday, Tuesday, Wednesday and Thursday.
      if(DayOfWeek4()==1 || DayOfWeek4()==2 || DayOfWeek4()==3 || DayOfWeek4()==4 || DayOfWeek4()==5)
        {
         int total_t=PositionsTotal();
         double selected_Profit_Swap=0;
         double selected_TradeLotSize=0;
         string selected_OrderCommentCode;
         long   selected_Magic_ID;
         string selected_Symbol;
         double OrderProfit,OrderSwap,OrderLots,OrderOpenPrice,selected_OrderContractSize;
         string OrderComment;
         long OrderTicket;
         bool exitTriggered=false;
         ENUM_POSITION_TYPE OrderType=0;

         //Exit individual trades (Except Level_1);
         for(int i=0; i<total_t; i++)
           {
            PS=PositionGetTicket(i);
            OrderMagicNumber=PositionGetInteger(POSITION_MAGIC);
            OrderProfit=PositionGetDouble(POSITION_PROFIT);
            OrderSwap=PositionGetDouble(POSITION_SWAP);
            OrderComment=PositionGetString(POSITION_COMMENT);
            OrderLots=PositionGetDouble(POSITION_VOLUME);
            OrderTicket=PositionGetInteger(POSITION_TICKET);
            OrderOpenPrice=PositionGetDouble(POSITION_PRICE_OPEN);
            OrderType=(ENUM_POSITION_TYPE)(PositionGetInteger(POSITION_TYPE));

            if(OrderMagicNumber==ax_Magic_ID_Model_Long)
              {
               selected_Profit_Swap=(OrderProfit+OrderSwap);
               selected_OrderCommentCode=OrderComment;
               selected_TradeLotSize=OrderLots;
               selected_Magic_ID=OrderMagicNumber;
               selected_Symbol=PositionGetString(POSITION_SYMBOL);
               selected_OrderContractSize=SymbolInfoDouble(selected_Symbol,SYMBOL_TRADE_CONTRACT_SIZE);
               if(selected_Profit_Swap>ax_getTargetDollarAmount(selected_Symbol,ax_Enable_Dynamic_Lot_Volume_Set,selected_TradeLotSize)) exitTriggered=true;
               if(selected_Profit_Swap<ax_getStopLossDollarAmount(selected_Symbol,ax_Enable_Dynamic_Lot_Volume_Set,selected_TradeLotSize,OrderType)) exitTriggered=true;

               if(exitTriggered)
                 {
                  if(ax_Debug_Mode) Print("Ticket="+IntegerToString(OrderTicket)+" ::: Close Individal trade: "+selected_OrderCommentCode+" Profit_Dollar="+DoubleToString(selected_Profit_Swap));
                  trade.PositionClose(OrderTicket);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
// Function:    Calculate the take profit threshold
// Return:      Return the take profit threshold in dollar amount.
// Parameters:  No parameters.
// Desc:        The following function will calculate the dollar amount
//              for a 1% move of the selected asset.
//+------------------------------------------------------------------+
double ax_TakeProfit_Short_Trade_Threshold(string Psymbol,double PlotSizeVolume)
  {
   MqlTick latest_price;
   SymbolInfoTick(Psymbol,latest_price);
   double OrderContractSize=SymbolInfoDouble(Psymbol,SYMBOL_TRADE_CONTRACT_SIZE);
   double takeProfit_Threshold=((PlotSizeVolume*OrderContractSize*latest_price.ask*ax_getLotSizeMultiplier(ax_Enable_Dynamic_Lot_Volume_Set))*ax_EQ_TakeProfit_PCT);
   return(takeProfit_Threshold);
  }
//+------------------------------------------------------------------+
// Function:    Exit short side trades based on conditions.
// Return:      No value returned.
// Parameters:  PforceClose = Force close regardless of conditions
// Desc:        Close positions when conditions are met.            
//+------------------------------------------------------------------+
void ax_ExitShortTrade()
  {
//Trade only on Monday, Tuesday, Wednesday and Thursday.
   if(DayOfWeek4()==1 || DayOfWeek4()==2 || DayOfWeek4()==3 || DayOfWeek4()==4)
     {
      double collected_Profit_Client=0;
      double total=PositionsTotal();
      bool OS;
      long OrderMagicNumber;
      double OrderOpenPrice;
      long OrderTicket=0;
      double OrderProfit,OrderSwap;
      bool triggerExit=false;
      double OrderContractSize=0;
      double OrderLotVolume=0;
      string OrderSymbol;
      ENUM_POSITION_TYPE OrderType=0;
      MqlTick latest_price;

      for(int cnt=0; cnt<total; cnt++)
        {
         OS=PositionGetTicket(cnt);
         OrderMagicNumber=PositionGetInteger(POSITION_MAGIC);
         OrderSymbol = PositionGetString(POSITION_SYMBOL);
         OrderProfit = PositionGetDouble(POSITION_PROFIT);
         OrderLotVolume=PositionGetDouble(POSITION_VOLUME);
         OrderSwap=PositionGetDouble(POSITION_SWAP);
         OrderTicket=PositionGetInteger(POSITION_TICKET);
         OrderOpenPrice=PositionGetDouble(POSITION_PRICE_OPEN);
         OrderContractSize=SymbolInfoDouble(OrderSymbol,SYMBOL_TRADE_CONTRACT_SIZE);
         OrderType=(ENUM_POSITION_TYPE)(PositionGetInteger(POSITION_TYPE));
         SymbolInfoTick(OrderSymbol,latest_price);
         if(OrderMagicNumber==ax_Magic_ID_Model_Short)
           {
            collected_Profit_Client=OrderProfit+OrderSwap;
            if(collected_Profit_Client>ax_TakeProfit_Short_Trade_Threshold(OrderSymbol,OrderLotVolume)) triggerExit=true;
            if(collected_Profit_Client<((ax_getStopLossDollarAmount(OrderSymbol,ax_Enable_Dynamic_Lot_Volume_Set,OrderLotVolume,OrderType)))) triggerExit=true;
            if(triggerExit) {
               if(ax_Debug_Mode) Print("Ticket="+IntegerToString(OrderTicket)+" ::: Close Individal trade: Short Equity");
                trade.PositionClose(OrderTicket);
            }
           }
        }
     }
  }
//+------------------------------------------------------------------+
// Function:    Check if allow closing positions
// Return:      Return true if allowed to close based on NAV
// Parameters:  No Parameters.
// Desc:        This function check if the target NAV has been reached.
//              if target reached then return true.
//            
//+------------------------------------------------------------------+
bool ax_Nav_Target_Reached()
  {
   bool returned_Value=false;
   if(ax_Target_NAV<ax_Get_Net_Asset_Value())
     {
      returned_Value= true;
      ax_Target_NAV =(ax_Get_Net_Asset_Value()*0.05)+ax_Get_Net_Asset_Value();
     }
   ObjectCreate4("ObjTargetNAV",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjTargetNAV","Target(NAV): "+DoubleToString(ax_Target_NAV),10,"Verdana",White);
   ObjectSet4("ObjTargetNAV",OBJPROP_CORNER,0);
   ObjectSet4("ObjTargetNAV",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjTargetNAV",OBJPROP_YDISTANCE,160);
   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Exit all trades in the basket while condition reach.
// Return:      Return true if conditions met.
// Parameters:  Parameters description
// Desc:        Description of the function
//            
//+------------------------------------------------------------------+
bool ax_ExitTradeOnCondition(double PcurrentAsk)
  {
   ax_ExitShortTrade();
   ax_ExitLongTrade();
   ax_Exit_FX_Trade();
   return(true);
  }
//+------------------------------------------------------------------+
// Function:    Identify if max number of short/long trades are used.
// Return:      Return true if max not attained.
// Parameters:  Pmagic_ID_Model_Short = Short Trade Magic ID
//              Pmagic_ID_Model_Long  = Long Trade Magic ID
//              PSymbol_Price = Price of the instrument.
//              Pcontract_Size = Number of contract per lot.
//              Plot_Size_Volume = Volume of the trade.
//
// Desc:        This function locate and count the number of trade
//              and count the number of shorts. return true if the
//              number of short trades are less than 50% of the total
//              opened positions or long trades are less than 50% depending
//              on specified parameter.
//+------------------------------------------------------------------+
bool ax_CanOpenMore_Trade_By_ID(long Pmagic_ID,double Psymbol_Price,double Pcontract_Size,double Plot_Size_Volume)
  {
   double TotalOrders=ax_Get_Composite_Index_Number_Orders();
   bool isAboveiMA= ax_Benchmark_IsAbove_iMA(ax_Benchmark_Symbol,ax_Equity_iMA_Period,ax_iMA_Period_Default);
   long OrderMagic=0;
   double Number_of_Trade_By_ID=0;
   double Allowed_PCT_Trade_By_ID = 0.5;
   double Current_PCT_Trade_By_ID = 0;
   bool returned_Value=false;

   if(Pmagic_ID == ax_Magic_ID_Model_Long) Allowed_PCT_Trade_By_ID = 0.7;
   if(Pmagic_ID == ax_Magic_ID_Model_Short) Allowed_PCT_Trade_By_ID = 0.4;


   for(int i=0; i<=TotalOrders; i++)
     {
      PositionGetTicket(i);
      OrderMagic=PositionGetInteger(POSITION_MAGIC);
      if(OrderMagic==Pmagic_ID) Number_of_Trade_By_ID++;
     }

   if(TotalOrders==0) TotalOrders=ax_Allowed_Orders();
   Current_PCT_Trade_By_ID=(Number_of_Trade_By_ID/TotalOrders);
   if(Current_PCT_Trade_By_ID<Allowed_PCT_Trade_By_ID) returned_Value=true; else returned_Value=false;

   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Identify the price if above or below the benchmark
// Return:      True if above the benchmark.
// Parameters:  Pbenchmark = Benchmark
//              Pperiod = period of moving average.
//              PTimeframe = Ptimeframe 
// Desc:        The function return true if the price of the benchmark
//              is above the selected parameters moving average.
//+------------------------------------------------------------------+
bool ax_Benchmark_IsAbove_iMA(string Pbenchmark,ENUM_TIMEFRAMES Ptimeframe,int Pperiod)
  {
   MqlTick benchmark_Price;
   SymbolInfoTick(Pbenchmark,benchmark_Price);
   bool returned_Value=false;
   double iMA_Price=ax_ComputeTechIndicators(ax_Benchmark_Symbol,"iMA",Ptimeframe,Pperiod,0);
   if(iMA_Price<benchmark_Price.ask) returned_Value=true;
   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Get Composite Index number of running trades
// Return:      Returned the number of active Orders as an integer
// Parameters:  No Parameters.
// Desc:        This function count the number of active orders
//              related to the composite index.
//+------------------------------------------------------------------+
int ax_Get_Composite_Index_Number_Orders()
  {
   int TotalPos=PositionsTotal();
   long selected_Magic=0;
   int count_O=0;
   for(int i=0; i<=TotalPos; i++)
     {
      PositionGetTicket(i);
      selected_Magic=PositionGetInteger(POSITION_MAGIC);
      if(selected_Magic==ax_Magic_ID_Model_Long || selected_Magic==ax_Magic_ID_Model_Short)
         count_O++;
     }

   return(count_O);
  }
//+------------------------------------------------------------------+
// Function:    Check if the overall strategy is in drawdown and 
//              and set specific amount of order to trade as per the
//              risk exposure.
// Return:      Returned the number of allowed Orders as an integer
// Parameters:  No Paramters.
// Desc:        This function check if the strategy is experiencing 
//              any drawdown and set the number of allowed trade 
//              according to the risk exposure.
//+------------------------------------------------------------------+
double ax_Allowed_Orders()
  {
   double Net_Asset_Value=ax_Get_Net_Asset_Value();
   double Current_Drawdown=0;
   double Allowed_Orders=NormalizeDouble(((ax_Risk_Level_Set/ax_Base_Account_Dollar_Amount)*AccountInfoDouble(ACCOUNT_EQUITY)),0);
   double Additional_Orders=0;
   double Additional_Orders_Every_PCT=ax_Equity_Ad_Additonal_Pos_At_DD;
   double returned_Value=0;

   if(ax_Reference_NAV<Net_Asset_Value)
      ax_Reference_NAV=Net_Asset_Value;
   else
     {
      Current_Drawdown=(Net_Asset_Value/ax_Reference_NAV)-1;
      Additional_Orders=NormalizeDouble((MathAbs(Current_Drawdown)/Additional_Orders_Every_PCT),0);
     }
   returned_Value=(int)(Allowed_Orders+Additional_Orders);
   if(returned_Value>ax_Number_Of_Components) returned_Value=(int)(ax_Number_Of_Components);
   if(returned_Value<ax_Risk_Level) returned_Value=(int)(ax_Risk_Level);

   ObjectCreate4("ObjExposureMGMT",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjExposureMGMT","Allocation="+IntegerToString(ax_Get_Composite_Index_Number_Orders())+"/"+DoubleToString(returned_Value)+"    Ref(NAV): "+DoubleToString(ax_Reference_NAV),10,"Verdana",White);
   ObjectSet4("ObjExposureMGMT",OBJPROP_CORNER,0);
   ObjectSet4("ObjExposureMGMT",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjExposureMGMT",OBJPROP_YDISTANCE,180);

   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Return Random integer within specific range
// Return:      Return a random integer
// Parameters:  PminValue = the min. of the range and PmaxValue the max.
// Desc:        The function returns the value of an integer randomly.
//+------------------------------------------------------------------+
int ax_MathRandomBounds(int PminValue,int PmaxValue)
  {
   return((int)(PminValue + MathRound((PmaxValue-PminValue)*(MathRand()/32767.0))));
  }
//+------------------------------------------------------------------+
// Function:    Enter all trades for the determined level.
// Return:      No value returned.
// Parameters:  Pmagic_ID = Magic number of the determined level.
// Desc:        Execute all trades for a particular level. Level is
//              identified by the magic ID.
//+------------------------------------------------------------------+
void executeIndexCompositeTrades(int Pmagic_ID)
  {
   MqlTick latest_price;
   int TotalComponent=ax_Number_Of_Components;
   double Max_Allowed_Orders=ax_Allowed_Orders();
   string Index_Component_X;
   double Index_Component_X_LotSize=0,Index_Component_X_Price=0,Index_Component_X_ContractSize=1;
   double Is_Above_MA=false;
   int j=0,k=0;

   for(int i=1; i<=TotalComponent; i++)
     {
      if(!ax_Random_Walk_Theory) j=i; else j=ax_MathRandomBounds(1,TotalComponent);
      switch(j)
        {
         case 1: Index_Component_X = ax_Index_Component[1]; break;
         case 2: Index_Component_X = ax_Index_Component[2]; break;
         case 3: Index_Component_X = ax_Index_Component[3]; break;
         case 4: Index_Component_X = ax_Index_Component[4]; break;
         case 5: Index_Component_X = ax_Index_Component[5]; break;
         case 6: Index_Component_X = ax_Index_Component[6]; break;
         case 7: Index_Component_X = ax_Index_Component[7]; break;
         case 8: Index_Component_X = ax_Index_Component[8]; break;
         case 9: Index_Component_X = ax_Index_Component[9]; break;
         case 10: Index_Component_X = ax_Index_Component[10]; break;
         case 11: Index_Component_X = ax_Index_Component[11]; break;
         case 12: Index_Component_X = ax_Index_Component[12]; break;
         case 13: Index_Component_X = ax_Index_Component[13]; break;
         case 14: Index_Component_X = ax_Index_Component[14]; break;
         case 15: Index_Component_X = ax_Index_Component[15]; break;
         case 16: Index_Component_X = ax_Index_Component[16]; break;
         case 17: Index_Component_X = ax_Index_Component[17]; break;
         case 18: Index_Component_X = ax_Index_Component[18]; break;
         case 19: Index_Component_X = ax_Index_Component[19]; break;
         case 20: Index_Component_X = ax_Index_Component[20]; break;
        }
      SymbolInfoTick(Index_Component_X,latest_price);
      Index_Component_X_Price=SymbolInfoDouble(Index_Component_X,SYMBOL_ASK);
      Index_Component_X_ContractSize=SymbolInfoDouble(Index_Component_X,SYMBOL_TRADE_CONTRACT_SIZE);
      Index_Component_X_LotSize=SymbolInfoDouble(Index_Component_X,SYMBOL_VOLUME_MIN);
      Is_Above_MA=ax_ComputeTechIndicators(Index_Component_X,"iMA",ax_Equity_iMA_Period,ax_iMA_Period_Default,0)<latest_price.ask;
      if(Index_Component_X!="")
        {
         if(ax_Get_Composite_Index_Number_Orders()<=Max_Allowed_Orders)
           {
            //XXZ
            if(i<11 && Is_Above_MA && ax_CanOpenMore_Trade_By_ID(ax_Magic_ID_Model_Long,Index_Component_X_Price,Index_Component_X_ContractSize,Index_Component_X_LotSize))
               executeTrade(Index_Component_X,0,0,Index_Component_X+"_"+IntegerToString(ax_Magic_ID_Model_Long)+ax_OrderCommentCode,ax_Magic_ID_Model_Long,Index_Component_X_LotSize*ax_getLotSizeMultiplier(ax_Enable_Dynamic_Lot_Volume_Set));
            if(i>10 && !Is_Above_MA && ax_CanOpenMore_Trade_By_ID(ax_Magic_ID_Model_Short,Index_Component_X_Price,Index_Component_X_ContractSize,Index_Component_X_LotSize))
               executeTrade(Index_Component_X,1,0,Index_Component_X+"_"+IntegerToString(ax_Magic_ID_Model_Short)+ax_OrderCommentCode,ax_Magic_ID_Model_Short,Index_Component_X_LotSize*ax_getLotSizeMultiplier(ax_Enable_Dynamic_Lot_Volume_Set));
           }
        }
     }
  }
//+------------------------------------------------------------------+
// Function:    Enter positions on the long side.
// Return:      No value returned.
// Parameters:  No paramters requested.
// Desc:        Enter positions.
//+------------------------------------------------------------------+
void ax_EnterCIndexTrade()
  {
      executeIndexCompositeTrades(ax_Magic_ID_Model_Long);
  }
//+------------------------------------------------------------------+
// Function:    Exit FX Trade
// Return:      No value returned.
// Parameters:  No Parameters.
// Desc:        This function close FX positions based on specific 
//              conditions.
//+------------------------------------------------------------------+
void ax_Exit_FX_Trade()
  {
   bool isAboveMA_PCT=false;
   int AllPos=PositionsTotal();
   if(ax_getDistanceInPct_iMA(ax_Benchmark_Symbol,ax_FX_Hedge_iMA_Period,ax_iMA_Period_Default)>ax_iMA_Distance_vs_MA_Median) isAboveMA_PCT=true;
   if(isAboveMA_PCT)
     {
      int TotalPos=PositionsTotal();
      long selected_Ticket=0,selected_Magic=0;
      for(int i=0; i<=TotalPos; i++)
        {
         PositionGetTicket(i);
         selected_Magic=PositionGetInteger(POSITION_MAGIC);
         selected_Ticket=PositionGetInteger(POSITION_TICKET);
         if(selected_Magic==ax_Magic_ID_Model_FX_Hedging) trade.PositionClose(selected_Ticket);
        }
     }
   double collected_profit=0;
   for(int i=0; i<=AllPos; i++)
     {
      PositionGetTicket(i);
      collected_profit=collected_profit+PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
     }
   if(collected_profit>(AccountInfoDouble(ACCOUNT_EQUITY)/100))
     {
      for(int i=0; i<=AllPos; i++)
        {
         PositionGetTicket(i);
         trade.PositionClose(PositionGetInteger(POSITION_TICKET));
        }
     }
  }
//+------------------------------------------------------------------+
// Function:    Get Lot Size Volume for FX positions
// Return:      Volume Lot size.
// Parameters:  Pwhich_Instrument = "FX_Hedging_Pair", "FX_Arbitrage_Pair"
// Desc:        This function return the most adequate sizing for FX pairs.
//+------------------------------------------------------------------+
double ax_get_FX_LotVolume(string Pwhich_Instrument)
  {
   double returned_Value=0,multiplier=0;
   int AllPos=PositionsTotal(),number_of_Long_Pos=0;
   double Total_Long_Equity_Amount=0,FX_Pair_Dollar_Amount=0;
   long selected_Magic=0;
   string selected_Symbol="";
   for(int i=0; i<=AllPos; i++)
     {
      PositionGetTicket(i);
      selected_Magic=PositionGetInteger(POSITION_MAGIC);
      selected_Symbol=PositionGetString(POSITION_SYMBOL);
      if(selected_Magic==ax_Magic_ID_Model_Long)
        {
         number_of_Long_Pos++;
         for(int j=0; j<=ax_Number_Of_Components; j++)
           {
            if(selected_Symbol ==  ax_Index_Component_1) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[1];
            if(selected_Symbol ==  ax_Index_Component_2) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[2];
            if(selected_Symbol ==  ax_Index_Component_3) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[3];
            if(selected_Symbol ==  ax_Index_Component_4) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[4];
            if(selected_Symbol ==  ax_Index_Component_5) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[5];
            if(selected_Symbol ==  ax_Index_Component_6) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[6];
            if(selected_Symbol ==  ax_Index_Component_7) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[7];
            if(selected_Symbol ==  ax_Index_Component_8) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[8];
            if(selected_Symbol ==  ax_Index_Component_9) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[9];
            if(selected_Symbol ==  ax_Index_Component_10) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[10];
            if(selected_Symbol ==  ax_Index_Component_11) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[11];
            if(selected_Symbol ==  ax_Index_Component_12) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[12];
            if(selected_Symbol ==  ax_Index_Component_13) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[13];
            if(selected_Symbol ==  ax_Index_Component_14) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[14];
            if(selected_Symbol ==  ax_Index_Component_15) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[15];
            if(selected_Symbol ==  ax_Index_Component_16) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[16];
            if(selected_Symbol ==  ax_Index_Component_17) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[17];
            if(selected_Symbol ==  ax_Index_Component_18) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[18];
            if(selected_Symbol ==  ax_Index_Component_19) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[19];
            if(selected_Symbol ==  ax_Index_Component_20) Total_Long_Equity_Amount = Total_Long_Equity_Amount + ax_Index_Component_Dollar_Amount_Array[20];
           }
        }
     }
   if(Pwhich_Instrument=="FX_Hedging_Pair")
     {
      FX_Pair_Dollar_Amount=ax_FX_Equity_HedgingPair_Dollar_Amount;
      multiplier=Total_Long_Equity_Amount/(FX_Pair_Dollar_Amount);
      returned_Value=NormalizeDouble((SymbolInfoDouble(ax_FX_Equity_HedgingPair,SYMBOL_VOLUME_MIN)*multiplier),2);
      if(returned_Value<(SymbolInfoDouble(ax_FX_Equity_HedgingPair,SYMBOL_VOLUME_MIN))) returned_Value=SymbolInfoDouble(ax_FX_Equity_HedgingPair,SYMBOL_VOLUME_MIN);
     }
   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Enter FX Trade
// Return:      No value returned.
// Parameters:  No Parameters.
// Desc:        This function open FX trade based on specific conditions
//+------------------------------------------------------------------+
void ax_Enter_FX_Trade()
  {
   bool isAboveMA_PCT=false;
   bool isAboveMA=false;
   int AllPos=PositionsTotal();
   int NumberOfPos = 0;
   int NumberOfJPY = 0;
   double LotSize=ax_get_FX_LotVolume("FX_Hedging_Pair");
   long FX_Hedging_Pair_Magic=ax_Magic_ID_Model_FX_Hedging;
   string FX_Hedging_Pair_CommentCode=ax_OrderCommentCode_FX_Hedging;
   string FX_Symbol=ax_FX_Equity_HedgingPair;
   int TradeDirection=ax_FX_HedgeDirection;

   if(ax_getDistanceInPct_iMA(ax_Benchmark_Symbol,ax_FX_Hedge_iMA_Period,ax_iMA_Period_Default)>ax_iMA_Distance_vs_MA_Median) isAboveMA_PCT=true;
   isAboveMA=ax_Benchmark_IsAbove_iMA(ax_Benchmark_Symbol,ax_FX_Hedge_iMA_Period,ax_iMA_Period_Default);

   for(int i=0; i<=AllPos; i++)
     {
      PositionGetTicket(i);
      if(PositionGetInteger(POSITION_MAGIC)==ax_Magic_ID_Model_Long)
         NumberOfPos++;
      if(PositionGetInteger(POSITION_MAGIC)==1) NumberOfJPY++;
     }
   if(!isAboveMA)
     {
      if(NumberOfJPY<NumberOfPos)
        {
         for(int i=1; i<=NumberOfPos; i++)
            executeTrade(FX_Symbol,TradeDirection,0,FX_Hedging_Pair_CommentCode+IntegerToString(i),FX_Hedging_Pair_Magic,LotSize);
        }
     }
  }
//+------------------------------------------------------------------+
// Function:    Get LotSize for FX Arbitrage positions.
// Return:      Return, lot size.
// Parameters:  Psymbol = Symbol of instrument to check.
// Desc:        This function will compute the right volume to trade 
//              FX arbitrage.
//+------------------------------------------------------------------+
double ax_FX_Arb_get_LotSize(string Psymbol)
  {
   double returned_Value=0;
   returned_Value=ax_get_Symbol_Info(Psymbol,"minLotSize");
   return(returned_Value);
  }
//+------------------------------------------------------------------+
// Function:    Enter position if conditions are met.
// Return:      Return true if conditions met.
// Parameters:  
// Desc:        
//+------------------------------------------------------------------+
bool ax_EnterTradeOnCondition()
  {
   ax_Set_System_Mode_Risk_Level();
   CurrentAsk = ax_Compute_Composite_Index_Price(false);
   CurrentBid = ax_Compute_Composite_Index_Price(true);
   ax_Get_Net_Asset_Value();
   if(ax_Enable_Equity_Trading) ax_EnterCIndexTrade();
   if(ax_Enable_FX_Equity_Hedge) ax_Enter_FX_Trade();
   return(true);
  }
//+------------------------------------------------------------------+
// Function:    Execute trade if not existing position is in progress
// Return:      Return true if trade is entered, false if not.
// Parameters:  Pdirection=0 for long, Pdirection=1 for short.
//              Pdirection=2 for long pending, Pdirection=3 for short pending
//              Pppdistance=2, 4, 6, 8, 10.
//              PcommentCode="2PP-Pos" etc...
//              PopenPrice= represent the price for pending order. 
//              if set to 0, ignore for executeTrade that are not pending,
//              which is at the market price.
//+------------------------------------------------------------------+
void executeTrade(string Psymbol,int Pdirection,double PopenPrice,string PcommentCode,long Pmagic_ID_Model,double Plot_Size)
  {
   bool posExist=false;
   int total=PositionsTotal();
   bool OS;
   string OrderComment;
   MqlTradeRequest mrequest;
   MqlTradeResult mresult;
   MqlTick latest_price;

   for(int cnt=0; cnt<total; cnt++)
     {
      OS=PositionGetTicket(cnt);
      OrderComment=PositionGetString(POSITION_COMMENT);
      if(OrderComment==PcommentCode)
        {
         posExist=true;
        }
     }
   if(!posExist)
     {
      ZeroMemory(mrequest);
      mrequest.action= TRADE_ACTION_DEAL; mrequest.symbol = Psymbol; mrequest.volume = Plot_Size;
      mrequest.magic = Pmagic_ID_Model; mrequest.type_filling = ORDER_FILLING_IOC; mrequest.deviation=OrderSlippage;
      mrequest.comment=PcommentCode; SymbolInfoTick(Psymbol,latest_price);

      if(Pdirection==0)
        {
         mrequest.price= latest_price.ask; mrequest.sl = Ultimate_Long_SL; mrequest.tp = Ultimate_Long_TP;
         mrequest.type = ORDER_TYPE_BUY; OS = OrderSend(mrequest,mresult);
         if(ax_Debug_Mode) Print("*** ExecuteTrade (long)");
        }

      if(Pdirection==1)
        {
         mrequest.price= latest_price.bid; mrequest.sl = Ultimate_Short_SL; mrequest.tp = Ultimate_Short_TP;
         mrequest.type = ORDER_TYPE_SELL; OS = OrderSend(mrequest,mresult);
         if(ax_Debug_Mode) Print("*** ExecuteTrade (short)");
        }
     }
  }
//+------------------------------------------------------------------+
// Function:    Interface display
//Parameters:   PalgoName = Name of the Algorithm.
//              PcompanyName = Name of the company.
//              Pversion = Version of the Algorithm.
// Return:      No returned parameter.
//+------------------------------------------------------------------+
void SetInterface(string PalgoName,string PcompanyName,string Pversion)
  {
   ObjectCreate4("ObjAlgoName",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjAlgoName",PalgoName,15,"Verdana",White);
   ObjectSet4("ObjAlgoName",OBJPROP_CORNER,0);
   ObjectSet4("ObjAlgoName",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjAlgoName",OBJPROP_YDISTANCE,50);

   ObjectCreate4("ObjCompanyName",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjCompanyName",PcompanyName,10,"Verdana",White);
   ObjectSet4("ObjCompanyName",OBJPROP_CORNER,0);
   ObjectSet4("ObjCompanyName",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjCompanyName",OBJPROP_YDISTANCE,70);

   ObjectCreate4("ObjVersion",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjVersion","Ver: "+Pversion,10,"Verdana",White);
   ObjectSet4("ObjVersion",OBJPROP_CORNER,0);
   ObjectSet4("ObjVersion",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjVersion",OBJPROP_YDISTANCE,100);

   ObjectCreate4("ObjServerTime",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjServerTime","Server Time: "+IntegerToString(Hour4())+":"+IntegerToString(Minute4())+":"+IntegerToString(Seconds4()),10,"Verdana",White);
   ObjectSet4("ObjServerTime",OBJPROP_CORNER,0);
   ObjectSet4("ObjServerTime",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjServerTime",OBJPROP_YDISTANCE,120);

   ObjectCreate4("ObjMagicIDMaster",OBJ_LABEL,0,0,0);
   ObjectSetText4("ObjMagicIDMaster","Reserved MagicID: "+IntegerToString(ax_Magic_ID_Model_Long)+", "+IntegerToString(ax_Magic_ID_Model_Short)+", "+IntegerToString(ax_Magic_ID_Model_FX_Hedging)+" to "+IntegerToString((ax_Magic_ID_Model_Suffix+999)),10,"Verdana",White);
   ObjectSet4("ObjMagicIDMaster",OBJPROP_CORNER,0);
   ObjectSet4("ObjMagicIDMaster",OBJPROP_XDISTANCE,15);
   ObjectSet4("ObjMagicIDMaster",OBJPROP_YDISTANCE,200);


   ChartSetInteger(0,CHART_COLOR_GRID,DarkBlue);
   //ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,DarkBlue);
   //ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,DarkBlue);
   //ChartSetInteger(0,CHART_COLOR_CHART_UP,DarkBlue);
   //ChartSetInteger(0,CHART_COLOR_CHART_DOWN,DarkBlue);
   ChartSetInteger(0,CHART_COLOR_BACKGROUND,DarkBlue);
   
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MQL4 MIGRATION FUNCTIONS
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
int DayOfWeek4() { MqlDateTime tm; TimeCurrent(tm); return(tm.day_of_week);}
int Hour4() { MqlDateTime tm; TimeCurrent(tm); return(tm.hour);}
int Minute4() { MqlDateTime tm; TimeCurrent(tm); return(tm.min);}
int Seconds4(){ MqlDateTime tm; TimeCurrent(tm); return(tm.sec);}
//+------------------------------------------------------------------+
//| Set Object on chart                                                                 
//+------------------------------------------------------------------+
bool ObjectSet4(string name,
                int index,
                double value)
  {
   switch(index)
     {
      case OBJPROP_PRICE: ObjectSetDouble(0,name,OBJPROP_PRICE,1,value);return(true);
      case OBJPROP_TIME: ObjectSetInteger(0,name,OBJPROP_TIME,2,(int)value);return(true);
      case OBJPROP_COLOR: ObjectSetInteger(0,name,OBJPROP_COLOR,(int)value);return(true);
      case OBJPROP_STYLE: ObjectSetInteger(0,name,OBJPROP_STYLE,(int)value);return(true);
      case OBJPROP_WIDTH: ObjectSetInteger(0,name,OBJPROP_WIDTH,(int)value);return(true);
      case OBJPROP_BACK: ObjectSetInteger(0,name,OBJPROP_BACK,(int)value);return(true);
      case OBJPROP_RAY: ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,(int)value);return(true);
      case OBJPROP_ELLIPSE: ObjectSetInteger(0,name,OBJPROP_ELLIPSE,(int)value);return(true);
      case OBJPROP_SCALE: ObjectSetDouble(0,name,OBJPROP_SCALE,value);return(true);
      case OBJPROP_ANGLE: ObjectSetDouble(0,name,OBJPROP_ANGLE,value);return(true);
      case OBJPROP_ARROWCODE: ObjectSetInteger(0,name,OBJPROP_ARROWCODE,(int)value);return(true);
      case OBJPROP_TIMEFRAMES: ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,(int)value);return(true);
      case OBJPROP_DEVIATION: ObjectSetDouble(0,name,OBJPROP_DEVIATION,value);return(true);
      case OBJPROP_FONTSIZE: ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(int)value);return(true);
      case OBJPROP_CORNER: ObjectSetInteger(0,name,OBJPROP_CORNER,(int)value);return(true);
      case OBJPROP_XDISTANCE: ObjectSetInteger(0,name,OBJPROP_XDISTANCE,(int)value);return(true);
      case OBJPROP_YDISTANCE: ObjectSetInteger(0,name,OBJPROP_YDISTANCE,(int)value);return(true);
      case OBJPROP_LEVELCOLOR: ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,(int)value);return(true);
      case OBJPROP_LEVELSTYLE: ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,(int)value);return(true);
      case OBJPROP_LEVELWIDTH: ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,(int)value);return(true);
      default: return(false);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//| Set text object on chart                                                                  
//+------------------------------------------------------------------+
bool ObjectSetText4(string name,
                    string text,
                    int font_size,
                    string font="",
                    color text_color=CLR_NONE)
  {
   int tmpObjType=(int)ObjectGetInteger(0,name,OBJPROP_TYPE);
   if(tmpObjType!=OBJ_LABEL && tmpObjType!=OBJ_TEXT) return(false);
   if(StringLen(text)>0 && font_size>0)
     {
      if(ObjectSetString(0,name,OBJPROP_TEXT,text) && ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size))
        {
         if((StringLen(font)>0) && !ObjectSetString(0,name,OBJPROP_FONT,font)) return(false);
         if( (text_color>0) && !ObjectSetInteger(0,name,OBJPROP_COLOR,text_color)) return(false);
         return(true);
        }
      return(false);
     }
   return(false);
  }
bool ObjectCreate4(string name,ENUM_OBJECT type,int window,datetime time1,double price1,datetime time2=0,double price2=0,
                   datetime time3=0,double price3=0){ return(ObjectCreate(0,name,type,window,time1,price1,time2,price2,time3,price3));}
                   //+------------------------------------------------------------------+
