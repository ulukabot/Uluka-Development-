//+------------------------------------------------------------------+
//| Uluka Ultra © Master Version                                      |
//| Build 17 — Claude Edition                                         |
//| Full SMC + Institutional + Fund Management Engine                 |
//| Upgraded by Claude AI — All features production ready             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, UlukaUltrafx"
#property strict
#property icon "\\Images\\UlukaUltra.ico"
#resource "\\Images\\UlukaUltra.bmp"
#include <Trade/Trade.mqh>
#include <UlukaIntelligence.mqh>

CTrade trade;

//+------------------------------------------------------------------+
//| ENUMERATIONS                                                      |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY_MODE { ULUKA_Vision, ULUKA_Farsight };
ENUM_STRATEGY g_last_trade_strategy = STRATEGY_FARSIGHT;

//+------------------------------------------------------------------+
//| CONSTANTS                                                         |
//+------------------------------------------------------------------+
const string DISCLAIMER     = "\n\n⚠️ This content is to demonstrate Uluka's Performance only, and SHOULD NOT BE TREATED AS FINANCIAL ADVICE";
const string MAKE_WEBHOOK_URL = "https://script.google.com/macros/s/AKfycbzsMJachLeCKsbnXhqg5fxBNGCVNOU2NG5Ke9H2FC4Iut-ntHktioCfZvgNWg0n-K578w/exec";

//+------------------------------------------------------------------+
//| ═══════════════════════════════════════════════════════════════  |
//| INPUT PARAMETERS — ORGANIZED INTO COLLAPSIBLE GROUPS             |
//| Each group has its own master toggle where applicable            |
//| ═══════════════════════════════════════════════════════════════  |
//+------------------------------------------------------------------+

//──────────────────────────────────────────────────────────────────
// GROUP 1 — CORE SETTINGS (Always visible — required)
//──────────────────────────────────────────────────────────────────
input group "🦉 ══ CORE SETTINGS ══"
input int    Magic_Number   = 123025;            // Magic Number
input string Licence_Key    = "YOUR KEY HERE";   // Your Licence Key
input string Server_URL     = "https://script.google.com/macros/s/AKfycbzsMJachLeCKsbnXhqg5fxBNGCVNOU2NG5Ke9H2FC4Iut-ntHktioCfZvgNWg0n-K578w/exec"; // Server URL
input bool   Test_Bypass    = false;             // BackTest Mode ON
input bool   Use_Stealth_SLTP = true;            // Stealth SL/TP Mode

//──────────────────────────────────────────────────────────────────
// GROUP 2 — RISK MANAGEMENT (Core — always visible)
//──────────────────────────────────────────────────────────────────
input group "🛡️ ══ RISK MANAGEMENT ══"
input double RISK_Per_Trade_Percent = 0.5;       // Risk Per Trade %
input double Daily_Loss_Limit       = 5.0;       // Max Daily Loss %
input double Floating_DD_Limit      = 3.0;       // Max Floating Loss %
input int    Max_Open_Trades        = 5;         // Max Open Trades Per Symbol
input double Profit_Ratio           = 4.5;       // {Profit Ratio (TP)%
input double Risk_Ratio             = 1.5;       // Risk Ratio (SL)%
input double Max_Equity_Cap         = 500.0;     // Equity Tier Cap ($)
input double Risk_Hard_Shield       = 500.0;     // Hard Risk Shield ($)
input double Minimum_Lot_size       = 0.01;      // Minimum Lot Size

//──────────────────────────────────────────────────────────────────
// GROUP 3 — TRADE EXECUTION (Core — always visible)
//──────────────────────────────────────────────────────────────────
input group "⚡ ══ TRADE EXECUTION ══"
input int    MaxSpread       = 40;               // Max Spread (pips)
input int    Max_Slippage    = 3;                // Max Slippage (points)
input int    Max_Retries     = 3;                // Max Retries on Failure

//──────────────────────────────────────────────────────────────────
// GROUP 4 — STRATEGY & AI (Core — always visible)
//──────────────────────────────────────────────────────────────────
input group "🧠 ══ STRATEGY & AI ══"
input ENUM_STRATEGY_MODE Strategy_Switch    = ULUKA_Vision; // Default Strategy
input int    Speed                          = 45;           // Speed
input double Strength                       = 1.7;          // Strength
input bool   Internal_AI_Sensor            = true;          // Uluka AI Trend Filter ON
input bool   Enable_SMC_Strategies         = true;          // Enable SMC Strategies (BOS/CHoCH/FVG/OB)
input bool   Enable_HTF_Bias_Filter        = true;          // Only trade with HTF trend bias
input int    Min_Confidence_Score          = 65;            // Minimum Confidence Score (0-100)

//──────────────────────────────────────────────────────────────────
// GROUP 5 — POSITION MANAGEMENT (Core — always visible)
//──────────────────────────────────────────────────────────────────
input group "📐 ══ POSITION MANAGEMENT ══"
input bool   Enable_BreakEven              = true;          // Enable Break-Even Automation
input int    BreakEven_Points              = 50;            // Break-Even trigger (points profit)
input bool   Enable_ATR_Trailing           = true;          // Enable SL Auto-Shift
input double ATR_Trail_Multiplier          = 1.5;           // SL Auto-Shift Multiplier
input int    Trailing_Start_Points         = 75;            // SL Auto-Shift Start (points profit)
input bool   Enable_Partial_Close          = false;         // Enable Partial Close (TP1/TP2)
input double TP1_RR_Ratio                  = 1.5;           // TP1 at X × SL distance (50% close)
input double TP2_RR_Ratio                  = 3.0;           // TP2 at X × SL distance (30% close)
input int    Symbol_Cooldown_Minutes       = 30;            // Cooldown after loss (minutes)

//──────────────────────────────────────────────────────────────────
// GROUP 6 — NEWS GUARD (Toggle: disable to skip)
//──────────────────────────────────────────────────────────────────
input group "📰 ══ NEWS GUARD (Toggle ON/OFF) ══"
input bool   Use_News_Filter               = true;          // ► Enable News Guard
input bool   Filter_High_Impact            = true;          // Block High Impact News
input bool   Filter_Medium_Impact          = false;         // Block Medium Impact News
input int    Mins_Before_News              = 30;            // Minutes Before News
input int    Mins_After_News               = 30;            // Minutes After News

//──────────────────────────────────────────────────────────────────
// GROUP 7 — SESSION ENGINE (Toggle: disable for 24/7 trading)
//──────────────────────────────────────────────────────────────────
input group "🕐 ══ SESSION ENGINE (Toggle ON/OFF) ══"
input bool   Enable_Session_Filter         = true;          // ► Enable Session Filter
input bool   Trade_Asian_Session           = false;         // Allow Asian Session Trading
input bool   Trade_London_Session          = true;          // Allow London Session
input bool   Trade_NY_Session              = true;          // Allow New York Session
input bool   Trade_Overlap_Session         = true;          // Allow London+NY Overlap (Best)

//──────────────────────────────────────────────────────────────────
// GROUP 8 — PROP FIRM MODE (Toggle: only matters when ON)
//──────────────────────────────────────────────────────────────────
input group "🏆 ══ PROP FIRM MODE (Set PROP_NONE to disable) ══"
input ENUM_PROP_FIRM Prop_Firm_Mode        = PROP_NONE;     // ► Select Prop Firm (NONE = disabled)
input bool   Prop_Override_Risk            = true;          // Auto-override risk to firm limits
input bool   Prop_Override_DD              = true;          // Auto-override DD limits to firm rules
input bool   Prop_Block_At_80Percent       = true;          // Block trading at 80% of limits

//──────────────────────────────────────────────────────────────────
// GROUP 9 — CAPITAL GROWTH GOVERNOR (Toggle: disable for fixed risk)
//──────────────────────────────────────────────────────────────────
input group "📈 ══ CAPITAL GROWTH GOVERNOR (Toggle ON/OFF) ══"
input bool   Enable_Growth_Governor        = true;          // ► Enable Auto Risk Scaling

//──────────────────────────────────────────────────────────────────
// GROUP 10 — GUARDIAN ANGEL (Toggle: disable to turn off 24/7 monitor)
//──────────────────────────────────────────────────────────────────
input group "👼 ══ GUARDIAN ANGEL 24/7 MONITOR (Toggle ON/OFF) ══"
input bool   Enable_Guardian_Angel         = true;          // ► Enable Guardian Angel
input double Guardian_Emergency_DD         = 8.0;           // Emergency DD % (close all + lock)

//──────────────────────────────────────────────────────────────────
// GROUP 11 — ACCOUNT HEALTH SCORE (Toggle: disable to hide)
//──────────────────────────────────────────────────────────────────
input group "🩺 ══ ACCOUNT HEALTH SCORE (Toggle ON/OFF) ══"
input bool   Enable_Health_Score           = true;          // ► Enable Health Score Display

//──────────────────────────────────────────────────────────────────
// GROUP 12 — DNA Fingerprint
//──────────────────────────────────────────────────────────────────
input group "🧬 ══ AI DNA FINGERPRINT (Toggle ON/OFF) ══"
input bool   Enable_DNA_Fingerprint = true;   // ► Enable AI Self Learning
input bool   DNA_Adjust_Risk        = true;   // Reduce risk in bad sessions
input bool   DNA_Block_Bad_Combos   = true;   // Block historically losing combos
input bool   DNA_Boost_Confidence   = true;   // Add DNA bonus to confidence score

//──────────────────────────────────────────────────────────────────
// GROUP 13 — TELEGRAM & SIGNALS (Toggle: disable for silent mode)
//──────────────────────────────────────────────────────────────────
input group "📡 ══ TELEGRAM & SIGNALS (Toggle ON/OFF) ══"
input bool   Enable_Telegram_Hoots         = true;          // ► Enable Telegram Signals
input string TG_API                        = "8395398421:AAE3kN0d1giB75vCvhtwSRroMEQTG1OgszA"; // API
input string TG_Premium_Group_ID           = "-1003671600619"; // Premium Channel ID
input string TG_Free_Group_ID              = "@UlukaUltra";    // Free Channel ID (public)
input string MyPersonalChatID              = "1085844653";     // Personal Chat (EOD Reports)
input int    Free_Signal_Limit             = 1;                // Max Free Signals Per Day

//──────────────────────────────────────────────────────────────────
// GROUP 14 — ON-SCREEN ALERTS (Toggle: disable for clean chart)
//──────────────────────────────────────────────────────────────────
input group "🔔 ══ ON-SCREEN ALERTS (Toggle ON/OFF) ══"
input bool   Show_OnScreen_Alerts          = true;          // ► Enable Pop-up Alerts
input int    Alert_Cooldown_Seconds        = 300;           // Alert Cooldown (seconds)

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                  |
//+------------------------------------------------------------------+
int      handle_bb;
int      handle_atr;
datetime last_news_check    = 0;
bool     news_status_cache  = false;

// Daily stats
double   g_daily_floating       = 0.0;
double   g_daily_realized_pnl   = 0.0;
double   g_day_start_equity     = 0.0;
double   g_day_start_time       = 0;
int      g_daily_trades_Count   = 0;
int      g_daily_trades         = 0;
int      g_daily_wins           = 0;
int      g_daily_losses         = 0;
double   g_daily_profit         = 0.0;
double   g_total_profit         = 0.0;
bool     g_daily_limit_hit      = false;

// All-time
double   g_initial_deposit      = 0.0;
double   g_alltime_pnl          = 0.0;

// State
bool     g_licence_valid        = false;
string   g_client_name          = "Customer";
bool     g_activation_sent      = false;
datetime g_last_licence_check   = 0;
datetime g_last_reset_day       = 0;
datetime g_last_report_time     = 0;
datetime g_last_trade_time      = 0;
datetime g_current_day          = 0;
int      g_days_left            = -1;
double   g_current_atr          = 0;
int      g_free_hoots_today     = 0;
bool     g_spread_alert_logged  = false;
bool     g_margin_alert_shown   = false;
bool     g_forced_hoot_sent     = false;
int      g_health_score         = 100;
string   g_instance_id          = "";
int      g_trading_days_count   = 0;  // For prop firm min days tracking

// Stealth SL/TP tracking
struct StealthLevels { ulong ticket; double sl; double tp; };
StealthLevels stealth_levels[];

// Flag files
string forced_hoot_flag_file = "Uluka_ForcedHootFlag_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + ".flag";

// Cooldown
const int TRADE_COOLDOWN_SECONDS = 300;

// UI
string UI_P       = "Uluka_";
color  UI_BG      = C'10,20,40';
color  UI_GOLD    = clrGoldenrod;
color  UI_TEXT    = clrWhite;
color  UI_ACCENT  = clrDodgerBlue;

//+------------------------------------------------------------------+
//| FORWARD DECLARATIONS                                              |
//+------------------------------------------------------------------+
void   ExecuteTrade(ENUM_ORDER_TYPE type, double atr_v);
bool   ULUKA_AI_Trend_Sensor_Confirm(ENUM_ORDER_TYPE type);
void   ManageInternalLevels();
void   UpdateDashboard();
void   SendHoot(ENUM_ORDER_TYPE type, double p, double sl, double tp, double lot, ulong ticket=0);
void   SendToTelegram(string chat_id, string text);
void   SendTelegramPhoto(string chat_id, string filename, string caption);
//void   SendLiveHootToApp(string symbol, string action, double price, string details);
bool   ValidateLicence();
string BuildTradeCardText(string group_header, ENUM_ORDER_TYPE type, double entry, double sl, double tp, double lot);
//bool   CreateAndCaptureTradeCard(string &out_filename, string group_header, ENUM_ORDER_TYPE type, double entry, double sl, double tp, double lot);
void   SendDailyEODReport();
void   CreateLabel(string name, string text, int x, int y, color clr=clrWhite);
string UrlEncode(string text);
string EscapeMarkdownV2(string text);
string Base64Encode(uchar &data[]);
void   SendTradeSignal(long tkt, string act, double prc, double stop, double prof, double lsize, string type="TRADE_SIGNAL");
void   SendTradeLog(double profit, string symbol, long magic);
void   UploadToWebhookBase64(string filename, string type);
bool   IsSessionAllowed();
double GetEffectiveRiskPercent();
bool   IsPropFirmCompliant(double dailyLossPercent, double totalDDPercent);
void   AddFormField(uchar &post_data[], int &pos, string boundary, string name, string value);
string GetInstanceID();
string getClientIp();
int    PositionsTotalByMagicAll();

//+------------------------------------------------------------------+
//| ONINIT                                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   // 1. Init Intelligence Library
   InitUlukaCore(_Symbol);

   // 2. Licence Validation
   g_licence_valid = ValidateLicence();
   if(!g_licence_valid && !MQLInfoInteger(MQL_TESTER))
      return(INIT_FAILED);

   // 3. Cloud Sync
   SyncWithCloud(Server_URL);

   // 4. Equity Cap Check
   if(AccountInfoDouble(ACCOUNT_EQUITY) > Max_Equity_Cap && !MQLInfoInteger(MQL_TESTER))
   {
      Alert("🦉 SECURITY HALT: Equity exceeds licensed tier ($", DoubleToString(Max_Equity_Cap, 0), ")");
      return(INIT_FAILED);
   }

   // 5. Initial Deposit tracking
   string deposit_file = "Uluka_InitialDeposit_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + ".dat";
   int dh = FileOpen(deposit_file, FILE_READ|FILE_TXT|FILE_COMMON);
   if(dh != INVALID_HANDLE)
   {
      g_initial_deposit = StringToDouble(FileReadString(dh));
      FileClose(dh);
   }
   else
   {
      g_initial_deposit = AccountInfoDouble(ACCOUNT_BALANCE);
      dh = FileOpen(deposit_file, FILE_WRITE|FILE_TXT|FILE_COMMON);
      if(dh != INVALID_HANDLE) { FileWriteString(dh, DoubleToString(g_initial_deposit, 2)); FileClose(dh); }
   }

   // 6. Load daily stats
   MqlDateTime ts; TimeToStruct(TimeCurrent(), ts);
   datetime today_start = StringToTime(StringFormat("%04d.%02d.%02d 00:00", ts.year, ts.mon, ts.day));
   g_current_day   = today_start;
   g_day_start_time = today_start;

   string stats_file = "Uluka_DailyStats_" + TimeToString(today_start, TIME_DATE) + ".dat";
   int sh = FileOpen(stats_file, FILE_READ|FILE_BIN|FILE_COMMON);
   if(sh != INVALID_HANDLE)
   {
      g_daily_realized_pnl  = FileReadDouble(sh);
      g_daily_trades_Count  = FileReadInteger(sh);
      g_daily_wins          = FileReadInteger(sh);
      g_daily_losses        = FileReadInteger(sh);
      FileClose(sh);
   }

   g_day_start_equity = AccountInfoDouble(ACCOUNT_BALANCE);
   g_alltime_pnl      = AccountInfoDouble(ACCOUNT_EQUITY) - g_initial_deposit;

   // 7. Indicators
   int p = (Strategy_Switch == ULUKA_Vision) ? Speed : 24;
   double d = (Strategy_Switch == ULUKA_Vision) ? Strength : 0.9;
   handle_bb  = iBands(_Symbol, PERIOD_CURRENT, p, 0, d, PRICE_CLOSE);
   handle_atr = iATR(_Symbol,  PERIOD_CURRENT, 11);
   if(handle_bb == INVALID_HANDLE || handle_atr == INVALID_HANDLE) return(INIT_FAILED);

   // 8. Trade settings
   trade.SetExpertMagicNumber(Magic_Number);
   trade.SetDeviationInPoints(Max_Slippage);

   // 9. Load stealth levels
   int slh = FileOpen("stealth_levels.dat", FILE_READ|FILE_BIN|FILE_COMMON);
   if(slh != INVALID_HANDLE) { FileReadArray(slh, stealth_levels); FileClose(slh); }

   // 10. Prop Firm info log
   if(Prop_Firm_Mode != PROP_NONE)
   {
      PropFirmLimits lim = GetPropFirmLimits(Prop_Firm_Mode);
      Print("🏆 PROP FIRM MODE: ", GetPropFirmName(Prop_Firm_Mode));
      Print("   Daily Loss Limit: ", lim.maxDailyLossPercent, "%");
      Print("   Max Total DD: ", lim.maxTotalDrawdownPercent, "%");
      Print("   Min Trading Days: ", lim.minTradingDays);
   }

   // 11. Activation alert
   if(g_licence_valid && !MQLInfoInteger(MQL_TESTER))
   {
      string msg = "🦉 MASTER OWL: Authorized!\n"
                 + "Account: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\n"
                 + "Tier: " + EnumToString(GetAccountTier()) + "\n"
                 + (Prop_Firm_Mode != PROP_NONE ? "Prop Mode: " + GetPropFirmName(Prop_Firm_Mode) + "\n" : "")
                 + "Time: " + TimeToString(TimeCurrent());
      string payload = "{\"type\":\"ActivationAlert\",\"text\":\"" + msg + "\"}";
      char data[], result[]; string res_headers;
      StringToCharArray(payload, data);
      WebRequest("POST", MAKE_WEBHOOK_URL, "Content-Type: application/json\r\n", 60000, data, result, res_headers);
   }

   // 12. Timer and dashboard
   EventSetTimer(300);
   if(!MQLInfoInteger(MQL_TESTER)) UpdateDashboard();

   Print("─────────────────────────────────");
   Print("🦉 Uluka Ultra Master v17 ONLINE");
   Print("🧠 SMC Engine: ", Enable_SMC_Strategies ? "ACTIVE" : "OFF");
   Print("🏆 Prop Mode: ", GetPropFirmName(Prop_Firm_Mode));
   Print("🕐 Session Filter: ", Enable_Session_Filter ? "ACTIVE" : "OFF");
   Print("👼 Guardian Angel: ", Enable_Guardian_Angel ? "ACTIVE" : "OFF");
   Print("📐 Break-Even: ", Enable_BreakEven ? "ACTIVE" : "OFF");
   Print("📈 SL Auto-Shift : ", Enable_ATR_Trailing ? "ACTIVE" : "OFF");
   Print("─────────────────────────────────");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| ONDEINIT                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Save stealth levels
   int h = FileOpen("stealth_levels.dat", FILE_WRITE|FILE_BIN|FILE_COMMON);
   if(h != INVALID_HANDLE) { FileWriteArray(h, stealth_levels); FileClose(h); }

   ObjectsDeleteAll(0, UI_P);
   IndicatorRelease(handle_bb);
   IndicatorRelease(handle_atr);
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| ONTIMER — Cloud sync + Guardian Angel                             |
//+------------------------------------------------------------------+
void OnTimer()
{
   // Cloud sync every 5 minutes
   SyncWithCloud(Server_URL);

   // Guardian Angel — 24/7 monitor
   if(Enable_Guardian_Angel)
      GuardianAngel(Magic_Number, Guardian_Emergency_DD, trade, MyPersonalChatID, TG_API);

   // Health Score update
   if(Enable_Health_Score)
   {
      double dailyFloating = GetCurrentFloatingPnL(Magic_Number);
      double floatDDPct    = (g_day_start_equity > 0) ?
                             MathMax(0, -dailyFloating / g_day_start_equity * 100.0) : 0;

      g_health_score = CalculateHealthScore(
         g_daily_realized_pnl,
         g_day_start_equity,
         g_daily_wins,
         g_daily_losses,
         G_ConsecutiveLosses,
         floatDDPct,
         Daily_Loss_Limit,
         RISK_Per_Trade_Percent
      );
   }

   // Dashboard refresh
   if(!MQLInfoInteger(MQL_TESTER)) UpdateDashboard();
}

//+------------------------------------------------------------------+
//| ONTICK                                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!g_licence_valid) return;

   // 1. Floating DD check (every tick)
   CheckFloatingDrawdown(Floating_DD_Limit, trade, Magic_Number);

   // 2. Smart gate — spread, kill switch, session, cooldown
   if(!UlukaSmartDecision(_Symbol, Magic_Number, MaxSpread)) return;

   // 3. Hourly licence check
   if(TimeCurrent() - g_last_licence_check >= 3600)
   {
      if(!ValidateLicence()) { ExpertRemove(); return; }
      g_last_licence_check = TimeCurrent();
   }

   // 4. Daily reset
   MqlDateTime curr; TimeToStruct(TimeCurrent(), curr);
   if(curr.day != g_last_reset_day)
   {
      g_daily_trades        = 0;
      g_daily_wins          = 0;
      g_daily_losses        = 0;
      g_daily_profit        = 0;
      g_daily_realized_pnl  = 0;
      g_daily_trades_Count  = 0;
      g_day_start_equity    = AccountInfoDouble(ACCOUNT_EQUITY);
      g_last_reset_day      = curr.day;
      g_daily_limit_hit     = false;
      g_spread_alert_logged = false;
      g_margin_alert_shown  = false;
      g_free_hoots_today    = 0;
      G_LastRiskResetDay    = 0;
      g_trading_days_count++;
      Print("🌅 New Day | Start Equity: $", DoubleToString(g_day_start_equity, 2),
            " | Trading Days: ", g_trading_days_count);
   }

   // 5. End-of-day report (23:59 server time)
   MqlDateTime now_dt; TimeToStruct(TimeCurrent(), now_dt);
   if(now_dt.hour == 23 && now_dt.min == 59 &&
      TimeCurrent() - g_last_report_time > 3600)
   {
      SendDailyEODReport();
      g_last_report_time = TimeCurrent();
   }

   // 6. Confidence filter
   int current_conf = CalculateConfidence(_Symbol);
   int target_conf  = MathMax(Min_Confidence_Score, GetAdaptiveMinConfidence());

   if(current_conf < target_conf)
   {
      Comment("🦉 Confidence: ", current_conf, "% | Target: ", target_conf,
              "%\nRegime: ", EnumToString(DetectMarketRegime(_Symbol, PERIOD_CURRENT)),
              "\nSession: ", GetSessionName(),
              "\nHealth: ", g_health_score, "/100");
      return;
   }

   // 7. Session filter
   if(Enable_Session_Filter && !IsSessionAllowed())
   {
      Comment("🦉 Session Closed: ", GetSessionName(), "\nWaiting for active session...");
      return;
   }

   // 8. Daily loss limit
   g_daily_profit = AccountInfoDouble(ACCOUNT_EQUITY) - g_day_start_equity;
   if(Daily_Loss_Limit > 0 && g_daily_profit < 0 &&
      MathAbs(g_daily_profit / g_day_start_equity * 100.0) >= Daily_Loss_Limit)
   {
      if(!g_daily_limit_hit)
      {
         Custom_Alert("DailyLoss", "CRITICAL: Daily Loss Limit Reached!");
         g_daily_limit_hit = true;
      }
      return;
   }

   // 9. Prop Firm compliance check
   if(Prop_Firm_Mode != PROP_NONE && Prop_Block_At_80Percent)
   {
      double dailyLossPct = (g_daily_profit < 0 && g_day_start_equity > 0) ?
                            MathAbs(g_daily_profit / g_day_start_equity * 100.0) : 0;
      double totalDDPct   = (g_initial_deposit > 0) ?
                            MathAbs((AccountInfoDouble(ACCOUNT_EQUITY) - g_initial_deposit) / g_initial_deposit * 100.0) : 0;

      if(!IsPropFirmCompliant(dailyLossPct, totalDDPct)) return;
   }

   // 10. News filter
   if(Use_News_Filter)
   {
      if(Filter_High_Impact && IsNewsTime(_Symbol)) return;
      if(Filter_Medium_Impact && IsMediumNewsTime(_Symbol)) return;
   }

   // 11. Trade cooldown
   if(TimeCurrent() - g_last_trade_time < TRADE_COOLDOWN_SECONDS) return;

   // 12. Position management (BE + Trailing + Partial)
   ManageInternalLevels();

   // 13. Read indicators
   double up[], lo[], atr[];
   ArraySetAsSeries(up,  true);
   ArraySetAsSeries(lo,  true);
   ArraySetAsSeries(atr, true);

   if(CopyBuffer(handle_bb,  1, 0, 3, up)  < 3) return;
   if(CopyBuffer(handle_bb,  2, 0, 3, lo)  < 3) return;
   if(CopyBuffer(handle_atr, 0, 0, 3, atr) < 3) return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   g_current_atr = atr[0];

   // 14. Signal detection
   bool buySignal  = false;
   bool sellSignal = false;

   // Classic BB signals (always available)
   bool bbBuy  = (bid <= lo[1] && bid > lo[2]);
   bool bbSell = (ask >= up[1] && ask < up[2]);

   if(bbBuy)  buySignal  = true;
   if(bbSell) sellSignal = true;

   // SMC signals (when enabled)
   if(Enable_SMC_Strategies)
   {
      ENUM_STRATEGY smcBuy  = GetRecommendedStrategy(_Symbol, ORDER_TYPE_BUY);
      ENUM_STRATEGY smcSell = GetRecommendedStrategy(_Symbol, ORDER_TYPE_SELL);

      if(smcBuy  != STRATEGY_STAY_OUT) buySignal  = true;
      if(smcSell != STRATEGY_STAY_OUT) sellSignal = true;
   }

   // 15. AI trend confirmation (classic filter)
   if(buySignal  && Internal_AI_Sensor && !ULUKA_AI_Trend_Sensor_Confirm(ORDER_TYPE_BUY))  buySignal  = false;
   if(sellSignal && Internal_AI_Sensor && !ULUKA_AI_Trend_Sensor_Confirm(ORDER_TYPE_SELL)) sellSignal = false;

   // 16. Execute
   if(buySignal)  ExecuteTrade(ORDER_TYPE_BUY,  atr[0]);
   if(sellSignal) ExecuteTrade(ORDER_TYPE_SELL, atr[0]);

   // 17. Dashboard update
   UpdateDashboard();
}

//+------------------------------------------------------------------+
//| ONTRANSACTION                                                     |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      if(HistoryDealSelect(trans.deal))
      {
         long magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
         if(magic != Magic_Number) return;

         string sym    = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
         double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
         long   entry  = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);

         if(entry == DEAL_ENTRY_OUT)
         {
            // Register with intelligence library
            RegisterTradeResult(profit);
            
            // DNA Fingerprint //
            int _sess = (int)GetCurrentSession();
       int _reg  = (int)DetectMarketRegime(_Symbol, PERIOD_H1);
      int _str  = (int)g_last_trade_strategy;
       RecordDNATrade(_Symbol, profit, _sess, _reg, _str);


            // Set cooldown if loss
            if(profit < 0)
               SetSymbolCooldown(sym, Symbol_Cooldown_Minutes);

            // Update stats
            g_daily_trades_Count++;
            if(profit > 0)  g_daily_wins++;
            else if(profit < 0) g_daily_losses++;
            g_total_profit       += profit;
            g_daily_realized_pnl += profit;

            // Save daily stats
            string sf = "Uluka_DailyStats_" + TimeToString(TimeCurrent(), TIME_DATE) + ".dat";
            int sh = FileOpen(sf, FILE_WRITE|FILE_BIN|FILE_COMMON);
            if(sh != INVALID_HANDLE)
            {
               FileWriteDouble(sh,  g_daily_realized_pnl);
               FileWriteInteger(sh, g_daily_trades_Count);
               FileWriteInteger(sh, g_daily_wins);
               FileWriteInteger(sh, g_daily_losses);
               FileClose(sh);
            }

            UpdateDashboard();

            // Cloud log
            SendTradeLog(profit, sym, magic);

            // Telegram close alert
            string status = (profit > 0.01) ? "✅ PROFIT" : (profit < -0.01) ? "❌ LOSS" : "⚖️ BREAKEVEN";
            string reason = (profit > 0.01) ? "TP Hit" : (profit < -0.01) ? "SL Hit" : "Breakeven";

            if(Enable_Telegram_Hoots)
            {
               string close_msg = "🦉 <b>TRADE CLOSED</b>\n"
                                 + "<b>Ticket:</b> " + IntegerToString(trans.deal) + "\n"
                                 + "<b>Symbol:</b> " + sym + "\n"
                                 + "<b>Result:</b> " + status + "\n"
                                 + "<b>Reason:</b> " + reason + "\n"
                                 + "<b>P&amp;L:</b> $" + DoubleToString(profit, 2) + "\n"
                                 + "<b>Daily P&amp;L:</b> $" + DoubleToString(g_daily_realized_pnl, 2) + "\n"
                                 + "<b>Health:</b> " + IntegerToString(g_health_score) + "/100 "
                                 + GetHealthScoreLabel(g_health_score) + "\n"
                                 + "<b>Time:</b> " + TimeToString(TimeCurrent()) + "\n\n"
                                 + DISCLAIMER;

               SendToTelegram(TG_Premium_Group_ID, close_msg);
               if(g_free_hoots_today < Free_Signal_Limit)
               {
                  SendToTelegram(TG_Free_Group_ID, "🆓 " + close_msg);
                  g_free_hoots_today++;
               }
            }

            PlaySound("hoot.wav");
            // SendLiveHootToApp(sym, "CLOSE", 0, "P&L: $" + DoubleToString(profit, 2));
         }
      }
   }
}

//+------------------------------------------------------------------+
//| EXECUTE TRADE                                                     |
//+------------------------------------------------------------------+
void ExecuteTrade(ENUM_ORDER_TYPE type, double atr_v)
{
   // 1. News check (redundant safety — already checked in OnTick)
   if(Use_News_Filter && Filter_High_Impact && IsNewsTime(_Symbol)) return;

   // 2. Kill switch
   if(G_Global_Kill_Switch)
   {
      Custom_Alert("KillSwitch", "CRITICAL: Cloud Kill Switch is ACTIVE!");
      return;
   }

   // 3. Spread check
   if(!IsSpreadSafe(_Symbol, MaxSpread)) return;
   

   // 4. Strategy determination
   ENUM_STRATEGY strat = STRATEGY_FARSIGHT;
   string stratName    = "Uluka Vision";

   if(Enable_SMC_Strategies)
   {
      strat    = GetRecommendedStrategy(_Symbol, type);
      stratName = GetStrategyName(strat);

      if(strat == STRATEGY_STAY_OUT)
      {
         Print("🦉 Strategy Router: STAY_OUT — ", EnumToString(DetectMarketRegime(_Symbol, _Period)));
         return;
      }
   }
   else
   {
      // Classic strategy routing
      ENUM_MARKET_REGIME regime = DetectMarketRegime(_Symbol, _Period);
      if(regime == REGIME_CHAOTIC || regime == REGIME_LOW_VOL)
      {
         Print("🦉 Classic Mode: Market unfavourable (", EnumToString(regime), ")");
         return;
      }
      stratName = (regime == REGIME_TRENDING) ? "Uluka Farsight" : "Uluka Close Vision";
   }

   // 5. HTF Bias filter
   if(Enable_HTF_Bias_Filter)
   {
      ENUM_TREND_BIAS htfBias = GetHTFBias(_Symbol);
      if(type == ORDER_TYPE_BUY  && htfBias == BIAS_BEARISH) { Print("🦉 HTF Bias: BEARISH — BUY blocked"); return; }
      if(type == ORDER_TYPE_SELL && htfBias == BIAS_BULLISH)  { Print("🦉 HTF Bias: BULLISH — SELL blocked"); return; }
   }

   // 6. Pivot safety
   PivotPoints pvt  = GetDailyPivots(_Symbol);
   double      price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                                                 : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(type == ORDER_TYPE_BUY  && price > pvt.R1) { Custom_Alert("PivotLong",  "REJECTED: Price above Daily R1"); return; }
   if(type == ORDER_TYPE_SELL && price < pvt.S1) { Custom_Alert("PivotShort", "REJECTED: Price below Daily S1"); return; }

   // 7. Correlation filter
   if(IsCorrelatedPositionOpen(_Symbol, type, Magic_Number))
   {
      Custom_Alert("Correlation", "REJECTED: Correlated position already open");
      return;
   }

   // 8. Position limit
   if(PositionsTotalByMagic(_Symbol, Magic_Number) >= Max_Open_Trades)
   {
      Custom_Alert("MaxTrades", "REJECTED: Max open trades reached (" + IntegerToString(Max_Open_Trades) + ")");
      return;
   }

   // 9. Effective risk calculation
   double effectiveRisk = GetEffectiveRiskPercent();
   if(effectiveRisk <= 0) { Print("🛑 Risk = 0. Trading paused."); return; }
   

   // 10. SL/TP calculation
   double sl_dist  = atr_v * Risk_Ratio;
   double sl_price = (type == ORDER_TYPE_BUY) ? price - sl_dist : price + sl_dist;
   double tp_price = (type == ORDER_TYPE_BUY) ? price + sl_dist * Profit_Ratio
                                              : price - sl_dist * Profit_Ratio;

   // Upgrade SL using Order Block if available (SMC)
   if(Enable_SMC_Strategies)
   {
      OrderBlock ob = GetNearestOrderBlock(_Symbol, PERIOD_CURRENT, type);
      if(ob.valid)
      {
         double obSL = (type == ORDER_TYPE_BUY)  ? ob.bottom - _Point * 5
                                                  : ob.top    + _Point * 5;
         // Use OB-based SL if it's tighter (less risk) or similar
         if(type == ORDER_TYPE_BUY  && obSL > sl_price) sl_price = obSL;
         if(type == ORDER_TYPE_SELL && obSL < sl_price) sl_price = obSL;
      }
   }


   // 11. Lot size
   double stopPoints = MathAbs(price - sl_price) / _Point;
   double final_lot  = CalculateInstitutionalLot(_Symbol, stopPoints, effectiveRisk);
   if(final_lot <= 0.0) { Print("🛑 Lot size = 0. Risk lock active."); return; }

   // 12. Margin check
   double margin_req = 0.0;
   if(!OrderCalcMargin(type, _Symbol, final_lot, price, margin_req) ||
      margin_req > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
   {
      Custom_Alert("Margin", "TRADE FAILED: Insufficient margin for " + DoubleToString(final_lot, 2) + " lots");
      return;
   }

if(Enable_DNA_Fingerprint && ShouldDNABlockTrade(_Symbol, (int)strat)) return;
      if(Enable_DNA_Fingerprint && DNA_Adjust_Risk)
      effectiveRisk *= GetDNARiskMultiplier(_Symbol);

   // 13. Execution
   bool  success = false;
   ulong ticket  = 0;
   string comment = "🦉 " + stratName;

   for(int i = 0; i < Max_Retries; i++)
   {
      double open_sl = Use_Stealth_SLTP ? 0 : sl_price;
      double open_tp = Use_Stealth_SLTP ? 0 : tp_price;

      if(trade.PositionOpen(_Symbol, type, final_lot, price, open_sl, open_tp, comment))
      {
         success = true;
         ticket  = trade.ResultOrder();
         break;
      }
      Sleep(200);
   }

   if(success)
   {
      RegisterTradeExecution();
      g_last_trade_time = TimeCurrent();

      // Store stealth levels
      int idx = ArraySize(stealth_levels);
      ArrayResize(stealth_levels, idx + 1);
      stealth_levels[idx].ticket = ticket;
      stealth_levels[idx].sl     = sl_price;
      stealth_levels[idx].tp     = tp_price;

      Print("🚀 TRADE OPENED | Strategy: ", stratName,
            " | Lot: ", DoubleToString(final_lot, 2),
            " | SL: ", DoubleToString(sl_price, _Digits),
            " | TP: ", DoubleToString(tp_price, _Digits));

      Custom_Alert("TradeOpen", "TRADE OPENED! " + (type == ORDER_TYPE_BUY ? "BUY" : "SELL")
                  + " " + DoubleToString(final_lot, 2) + " | " + stratName);
      PlaySound("ok.wav");

      // Send trade signal
      SendTradeSignal(ticket, (type == ORDER_TYPE_BUY ? "BUY" : "SELL"),
                      price, sl_price, tp_price, final_lot);

      if(Enable_Telegram_Hoots)
         SendHoot(type, price, sl_price, tp_price, final_lot, ticket);
   }
   else
   {
      string err = trade.ResultRetcodeDescription();
      Print("❌ Trade Failed: ", err);
      Custom_Alert("TradeError", "TRADE FAILED: " + err);
      PlaySound("timeout.wav");
   }
}

//+------------------------------------------------------------------+
//| MANAGE INTERNAL LEVELS — BE + ATR Trailing + Stealth + Partial   |
//+------------------------------------------------------------------+
void ManageInternalLevels()
{
   // Step 1 — Break-Even (before trailing, so BE is set first)
   if(Enable_BreakEven)
      ManageBreakEven(_Symbol, Magic_Number, BreakEven_Points, trade);

   // Step 2 — ATR Adaptive Trailing
   if(Enable_ATR_Trailing)
      ManageAdaptiveTrailing(_Symbol, Magic_Number, ATR_Trail_Multiplier,
                              Trailing_Start_Points, trade);

   // Step 3 — Partial Close
   if(Enable_Partial_Close)
      ManagePartialClose(_Symbol, Magic_Number, trade, TP1_RR_Ratio, TP2_RR_Ratio, 0);

   // Step 4 — Stealth SL/TP enforcement
   if(!Use_Stealth_SLTP) return;

   double point   = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

   for(int i = ArraySize(stealth_levels) - 1; i >= 0; i--)
   {
      ulong ticket = stealth_levels[i].ticket;
      if(!PositionSelectByTicket(ticket))
      {
         ArrayRemove(stealth_levels, i, 1);
         continue;
      }
      if(PositionGetInteger(POSITION_MAGIC)  != Magic_Number) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol)     continue;

      double bid   = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask   = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double curr_sl = stealth_levels[i].sl;
      double curr_tp = stealth_levels[i].tp;

      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
         if(bid <= curr_sl || bid >= curr_tp)
         {
            trade.PositionClose(ticket);
            Print("🦉 Stealth Close BUY #", ticket, " | SL:", curr_sl, " TP:", curr_tp);
            ArrayRemove(stealth_levels, i, 1);
         }
      }
      else
      {
         if(ask >= curr_sl || ask <= curr_tp)
         {
            trade.PositionClose(ticket);
            Print("🦉 Stealth Close SELL #", ticket, " | SL:", curr_sl, " TP:", curr_tp);
            ArrayRemove(stealth_levels, i, 1);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| DASHBOARD (Upgraded — Health Score + Session + Strategy)         |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   int x = 15, y = 15, sp = 22, width = 280, height = 560;

   // Background
   if(ObjectFind(0, UI_P+"BG") < 0)
   {
      ObjectCreate(0, UI_P+"BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, UI_P+"BG", OBJPROP_XSIZE,       width);
      ObjectSetInteger(0, UI_P+"BG", OBJPROP_YSIZE,       height);
      ObjectSetInteger(0, UI_P+"BG", OBJPROP_BGCOLOR,     UI_BG);
      ObjectSetInteger(0, UI_P+"BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, UI_P+"BG", OBJPROP_CORNER,      CORNER_LEFT_UPPER);
      ObjectSetInteger(0, UI_P+"BG", OBJPROP_COLOR,       UI_ACCENT);
      ObjectSetInteger(0, UI_P+"BG", OBJPROP_WIDTH,       2);
   }

   double daily_floating  = GetCurrentFloatingPnL(Magic_Number);
   double daily_total_pnl = g_daily_realized_pnl + daily_floating;
   double all_time_pnl    = AccountInfoDouble(ACCOUNT_EQUITY) - g_initial_deposit;
   double win_rate        = (g_daily_trades_Count > 0) ?
                            (g_daily_wins * 100.0 / g_daily_trades_Count) : 0.0;

   // Health score colors
   color health_color = (g_health_score >= 70) ? clrLime :
                        (g_health_score >= 50) ? clrYellow : clrTomato;

   // Session color
   ENUM_SESSION sess = GetCurrentSession();
   color sess_color  = (sess == SESSION_OVERLAP) ? clrGold :
                       (sess == SESSION_LONDON || sess == SESSION_NEW_YORK) ? clrLime :
                       (sess == SESSION_ASIAN) ? clrSilver : clrDimGray;

   // Title
   CreateLabel(UI_P+"H1", "🦉 ULUKA ULTRA MASTER", x, y, UI_ACCENT); y += 30;
   CreateLabel(UI_P+"SB", "🔇 STEALTH MODE | Cloud Only", x, y, clrDimGray); y += sp;

   // Client info
   CreateLabel(UI_P+"L1", "👤 " + g_client_name,                             x, y, UI_TEXT);    y += sp;
   CreateLabel(UI_P+"L2", "🆔 " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)), x, y, UI_TEXT); y += sp;

   // Status line
   color ai_color = Internal_AI_Sensor ? clrLime : clrGray;
   CreateLabel(UI_P+"L3", "🧠 AI: " + (Internal_AI_Sensor ? "ON" : "OFF")
              + "  SMC: " + (Enable_SMC_Strategies ? "ON" : "OFF"),    x, y, ai_color); y += sp;

   // Health Score
   CreateLabel(UI_P+"LH", "🩺 HEALTH: " + IntegerToString(g_health_score)
              + "/100 " + GetHealthScoreLabel(g_health_score),          x, y, health_color); y += sp;

   // Session
   CreateLabel(UI_P+"LS", "🕐 SESSION: " + GetSessionName(),           x, y, sess_color); y += sp;

   // Regime + Strategy
   ENUM_MARKET_REGIME regime = DetectMarketRegime(_Symbol, PERIOD_CURRENT);
   ENUM_TREND_BIAS    htf    = GetHTFBias(_Symbol);
   string htfStr = (htf == BIAS_BULLISH) ? "📈 BULL" : (htf == BIAS_BEARISH) ? "📉 BEAR" : "➡️ NEUTRAL";

   CreateLabel(UI_P+"LR", "📊 " + EnumToString(regime) + " | HTF: " + htfStr, x, y, UI_ACCENT); y += sp;

   // Prop Firm mode
   if(Prop_Firm_Mode != PROP_NONE)
   {
      CreateLabel(UI_P+"LPF", "🏆 PROP: " + GetPropFirmName(Prop_Firm_Mode), x, y, clrGold); y += sp;
   }

   y += 5;
   CreateLabel(UI_P+"L7", "📊 SYMBOL: " + _Symbol,                    x, y, UI_ACCENT); y += sp;
   CreateLabel(UI_P+"L8", "✅ TRADES TODAY: " + IntegerToString(g_daily_trades_Count)
              + "  WR: " + DoubleToString(win_rate, 0) + "%",          x, y, UI_TEXT);   y += sp;

   color pnl_color = (daily_total_pnl >= 0) ? clrLime : clrTomato;
   CreateLabel(UI_P+"L9", "💰 DAILY P&L: $" + DoubleToString(daily_total_pnl, 2), x, y, pnl_color); y += sp;

   color apnl_color = (all_time_pnl >= 0) ? clrLime : clrTomato;
   CreateLabel(UI_P+"L10", "📈 ALL-TIME: $" + DoubleToString(all_time_pnl, 2),    x, y, apnl_color); y += sp;

   // Days left
   color exp_color = (g_days_left > 7) ? clrLime : (g_days_left > 3) ? clrYellow : clrTomato;
   CreateLabel(UI_P+"L11", "🔑 LICENCE: " + (g_days_left >= 0 ?
              IntegerToString(g_days_left) + " days left" : "Active"),  x, y, exp_color); y += sp;

   // Capital Protection Mode
   if(G_CapitalProtectionMode)
   {
      CreateLabel(UI_P+"LCP", "🛡️ CAPITAL PROTECTION ACTIVE",         x, y, clrOrange); y += sp;
   }

   y += 8;

   // One-click exit button
   string btnName = UI_P + "ExitBtn";
   if(ObjectFind(0, btnName) < 0)
   {
      ObjectCreate(0, btnName, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, btnName, OBJPROP_XDISTANCE,  x + 15);
      ObjectSetInteger(0, btnName, OBJPROP_YDISTANCE,  y + 30);
      ObjectSetInteger(0, btnName, OBJPROP_XSIZE,      200);
      ObjectSetInteger(0, btnName, OBJPROP_YSIZE,      28);
      ObjectSetString(0,  btnName, OBJPROP_TEXT,       "🛑 CLOSE ALL POSITIONS");
      ObjectSetInteger(0, btnName, OBJPROP_BGCOLOR,    C'139,0,0');
      ObjectSetInteger(0, btnName, OBJPROP_COLOR,      clrWhite);
      ObjectSetInteger(0, btnName, OBJPROP_FONTSIZE,   9);
   }

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| SESSION ALLOWED CHECK                                             |
//+------------------------------------------------------------------+
bool IsSessionAllowed()
{
   if(!Enable_Session_Filter) return true;

   ENUM_SESSION sess = GetCurrentSession();

   switch(sess)
   {
      case SESSION_ASIAN:    return Trade_Asian_Session;
      case SESSION_LONDON:   return Trade_London_Session;
      case SESSION_NEW_YORK: return Trade_NY_Session;
      case SESSION_OVERLAP:  return Trade_Overlap_Session;
      case SESSION_CLOSED:   return false;
      default:               return false;
   }
}

//+------------------------------------------------------------------+
//| EFFECTIVE RISK CALCULATION                                        |
//+------------------------------------------------------------------+
double GetEffectiveRiskPercent()
{
   double risk = RISK_Per_Trade_Percent;

   // Capital Growth Governor
   if(Enable_Growth_Governor)
      risk = GetGovernedRiskPercent(risk, g_initial_deposit, AccountInfoDouble(ACCOUNT_BALANCE));

   // Prop Firm risk cap
   if(Prop_Firm_Mode != PROP_NONE && Prop_Override_Risk)
   {
      PropFirmLimits lim = GetPropFirmLimits(Prop_Firm_Mode);
      risk = MathMin(risk, lim.maxRiskPerTrade);
   }

   return risk;
}

//+------------------------------------------------------------------+
//| PROP FIRM COMPLIANCE CHECK                                        |
//+------------------------------------------------------------------+
bool IsPropFirmCompliant(double dailyLossPercent, double totalDDPercent)
{
   if(Prop_Firm_Mode == PROP_NONE) return true;
   return IsPropFirmSafe(Prop_Firm_Mode, dailyLossPercent, totalDDPercent);
}

//+------------------------------------------------------------------+
//| AI TREND SENSOR                                                   |
//+------------------------------------------------------------------+
bool ULUKA_AI_Trend_Sensor_Confirm(ENUM_ORDER_TYPE type)
{
   if(!Internal_AI_Sensor) return true;

   int maFastH = iMA(_Symbol, PERIOD_CURRENT, 10,    0, MODE_EMA, PRICE_CLOSE);
   int maSlowH = iMA(_Symbol, PERIOD_CURRENT, Speed, 0, MODE_EMA, PRICE_CLOSE);

   if(maFastH == INVALID_HANDLE || maSlowH == INVALID_HANDLE) return true;

   double maFast[], maSlow[];
   ArraySetAsSeries(maFast, true); ArraySetAsSeries(maSlow, true);
   bool ok = (CopyBuffer(maFastH, 0, 0, 3, maFast) >= 3 &&
              CopyBuffer(maSlowH, 0, 0, 3, maSlow) >= 3);
   IndicatorRelease(maFastH); IndicatorRelease(maSlowH);

   if(!ok) return true;

   return (type == ORDER_TYPE_BUY) ? (maFast[0] > maSlow[0]) : (maFast[0] < maSlow[0]);
}

//+------------------------------------------------------------------+
//| DAILY EOD REPORT                                                  |
//+------------------------------------------------------------------+
void SendDailyEODReport()
{
   if(!Enable_Telegram_Hoots) return;

   double floating    = GetCurrentFloatingPnL(Magic_Number);
   double total_pnl   = g_daily_realized_pnl + floating;
   double win_rate    = (g_daily_trades_Count > 0) ?
                        (g_daily_wins * 100.0 / g_daily_trades_Count) : 0.0;
   double balance     = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity      = AccountInfoDouble(ACCOUNT_EQUITY);

   string report = "🦉 <b>ULUKA DAILY EOD REPORT</b>\n"
                 + "📅 " + TimeToString(TimeCurrent(), TIME_DATE) + "\n\n"
                 + "👤 <b>Client:</b> " + g_client_name + "\n"
                 + "🆔 <b>Account:</b> " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "\n\n"
                 + "📊 <b>PERFORMANCE</b>\n"
                 + "✅ Trades: " + IntegerToString(g_daily_trades_Count) + "\n"
                 + "🏆 Wins: "   + IntegerToString(g_daily_wins) + "\n"
                 + "❌ Losses: " + IntegerToString(g_daily_losses) + "\n"
                 + "📈 Win Rate: " + DoubleToString(win_rate, 1) + "%\n\n"
                 + "💰 <b>P&amp;L</b>\n"
                 + "Realized: $" + DoubleToString(g_daily_realized_pnl, 2) + "\n"
                 + "Floating: $" + DoubleToString(floating, 2) + "\n"
                 + "Total: $"    + DoubleToString(total_pnl, 2) + "\n\n"
                 + "🏦 <b>ACCOUNT</b>\n"
                 + "Balance: $" + DoubleToString(balance, 2) + "\n"
                 + "Equity: $"  + DoubleToString(equity, 2) + "\n\n"
                 + "🩺 <b>Health Score:</b> " + IntegerToString(g_health_score)
                 + "/100 " + GetHealthScoreLabel(g_health_score) + "\n"
                 + (Prop_Firm_Mode != PROP_NONE ?
                   "🏆 <b>Prop Mode:</b> " + GetPropFirmName(Prop_Firm_Mode) + "\n" : "")
                 + "\n" + DISCLAIMER;

   // Send to personal chat, premium and admin
   SendToTelegram(MyPersonalChatID, report);
   SendToTelegram(TG_Premium_Group_ID, report);

   Print("📊 EOD Report Sent");
}

//+------------------------------------------------------------------+
//| CREATE LABEL                                                      |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color clr=clrWhite)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER,   CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0,  name, OBJPROP_FONT,     "Segoe UI");
   }
   ObjectSetString(0,  name, OBJPROP_TEXT,       text);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE,  x + 15);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE,  y);
   ObjectSetInteger(0, name, OBJPROP_COLOR,      clr);
}

//+------------------------------------------------------------------+
//| CHART EVENT — One-click exit                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == UI_P+"ExitBtn")
   {
      Print("🦉 One-Click Liquidation requested.");
      CloseAllEAOrders(trade, Magic_Number);
      ObjectSetInteger(0, UI_P+"ExitBtn", OBJPROP_STATE, false);
      Alert("🦉 MASTER OWL: All positions closed.");
   }
}

//+------------------------------------------------------------------+
//| SEND HOOT TO TELEGRAM                                             |
//+------------------------------------------------------------------+
void SendHoot(ENUM_ORDER_TYPE type, double p, double sl, double tp, double lot, ulong ticket=0)
{
   if(!Enable_Telegram_Hoots) return;

   ENUM_MARKET_REGIME regime     = DetectMarketRegime(_Symbol, _Period);
   ENUM_STRATEGY      strat      = Enable_SMC_Strategies ?
                                   GetRecommendedStrategy(_Symbol, type) : STRATEGY_FARSIGHT;
   int                confidence = CalculateConfidence(_Symbol);
   double             slDist     = MathAbs(p - sl);

   // ── Calculate multi-TP levels ──
   MultiTPLevels mtp = GetMultiTPLevels(
      _Symbol, type, p, sl,
      TP1_RR_Ratio,                // e.g. 1.5
      TP2_RR_Ratio,                // e.g. 3.0
      Profit_Ratio,                // e.g. 4.5 = TP3 (original single TP)
      lot
   );

   string direction = (type == ORDER_TYPE_BUY) ? "BUY 📈" : "SELL 📉";
   string rr1       = DoubleToString(MathAbs(mtp.tp1 - p) / slDist, 1);
   string rr2       = DoubleToString(MathAbs(mtp.tp2 - p) / slDist, 1);
   string rr3       = DoubleToString(MathAbs(mtp.tp3 - p) / slDist, 1);

   string signalText =
      "🦉 <b>ULUKA LIVE HOOT #" + IntegerToString(g_daily_trades_Count + 1) + "</b>\n\n"
      + "<b>Symbol:</b>     " + _Symbol + "\n"
      + "<b>Action:</b>     " + direction + "\n"
      + "<b>Strategy:</b>   " + GetStrategyName(strat) + "\n"
      + "<b>Regime:</b>     " + EnumToString(regime) + "\n"
      + "<b>Session:</b>    " + GetSessionName() + "\n"
      + "<b>Confidence:</b> <code>" + IntegerToString(confidence) + "%</code>\n"
      + "━━━━━━━━━━━━━━━━━\n"
      + "<b>Entry:</b> <code>" + DoubleToString(p,  _Digits) + "</code>\n"
      + "<b>SL:</b>    <code>" + DoubleToString(sl, _Digits)
      + "</code> <i>(" + DoubleToString(slDist / _Point, 0) + " pts)</i>\n"
      + "━━━━━━━━━━━━━━━━━\n"
      + "🎯 <b>TARGETS</b>\n"
      + "<b>TP1:</b> <code>" + DoubleToString(mtp.tp1, _Digits)
      + "</code>  RR 1:" + rr1 + "  <i>→ close 50%</i>\n"
      + "<b>TP2:</b> <code>" + DoubleToString(mtp.tp2, _Digits)
      + "</code>  RR 1:" + rr2 + "  <i>→ close 30%</i>\n"
      + "<b>TP3:</b> <code>" + DoubleToString(mtp.tp3, _Digits)
      + "</code>  RR 1:" + rr3 + "  <i>→ trail 20%</i>\n"
      + "━━━━━━━━━━━━━━━━━\n"
      + "<b>Lot:</b>    " + DoubleToString(lot, 2) + "\n"
      + "<b>Risk:</b>   " + DoubleToString(GetEffectiveRiskPercent(), 2) + "%\n"
      + "<b>Ticket:</b> " + (ticket > 0 ? IntegerToString(ticket) : "-") + "\n"
      + "<b>Health:</b> " + IntegerToString(g_health_score) + "/100 "
      + GetHealthScoreLabel(g_health_score) + "\n"
      + "<b>Time:</b>   " + TimeToString(TimeCurrent()) + "\n\n"
      + DISCLAIMER;

   // Build trade card
   /*string cardText = "LIVE HOOT #" + IntegerToString(g_daily_trades_Count + 1);
   string tradeCardFile;
   bool   cardSuccess = CreateAndCaptureTradeCard(tradeCardFile, cardText, type, p, sl, tp, lot);
   if(cardSuccess && FileIsExist(tradeCardFile))
      UploadToWebhookBase64(tradeCardFile, "TradeCard");

   // Deliver to groups
   SendToTelegram(TG_Premium_Group_ID, signalText);
   if(g_free_hoots_today < Free_Signal_Limit)
   {
      // Free group gets condensed version (no exact SL/TP, just direction + TP1 hint)
      string freeText =
         "🦉 <b>ULUKA FREE HOOT</b>\n\n"
         + (type == ORDER_TYPE_BUY ? "🟢" : "🔴")
         + " <b>" + (type == ORDER_TYPE_BUY ? "BUY" : "SELL")
         + "</b> " + _Symbol + "\n"
         + "Strategy: " + GetStrategyName(strat) + "\n"
         + "Session: "  + GetSessionName() + "\n"
         + "Targets: TP1 / TP2 / TP3 set ✅\n\n"
         + "🔑 <b>Full levels in Premium Channel</b>\n\n"
         + DISCLAIMER;

      SendToTelegram(TG_Free_Group_ID, freeText);
      g_free_hoots_today++;
   }

   PlaySound("hoot.wav");
   SendLiveHootToApp(_Symbol, direction, p,
      "TP1:" + DoubleToString(mtp.tp1, _Digits) +
      " TP2:" + DoubleToString(mtp.tp2, _Digits) +
      " TP3:" + DoubleToString(mtp.tp3, _Digits));*/
}

//+------------------------------------------------------------------+
//| SEND TO TELEGRAM (Fixed — HTML mode, no MarkdownV2 escape)        |
//+------------------------------------------------------------------+
void SendToTelegram(string chat_id, string text)
{
   if(chat_id == "" || chat_id == "0") return;

   // HTML mode — do NOT apply MarkdownV2 escaping
   string json = "{\"chat_id\":\"" + chat_id + "\","
                 "\"text\":\"" + text + "\","
                 "\"parse_mode\":\"HTML\","
                 "\"disable_web_page_preview\":true}";

   char data[], result[];
   StringToCharArray(json, data);

   string res_headers;
   string url = "https://api.telegram.org/bot" + TG_API + "/sendMessage";
   int res = WebRequest("POST", url, "Content-Type: application/json\r\n",
                        15000, data, result, res_headers);

   if(res == 200)
      Print("✅ Telegram sent to ", chat_id);
   else
   {
      Print("❌ Telegram failed: HTTP ", res, " | Error: ", GetLastError());
      if(res == -1 && GetLastError() == 4060)
         Custom_Alert("TG_Error", "Add 'https://api.telegram.org' to MT5 Allowed URLs!");
   }
}

//+------------------------------------------------------------------+
//| SEND TRADE SIGNAL TO CLOUD                                        |
//+------------------------------------------------------------------+
void SendTradeSignal(long tkt, string act, double prc, double stop, double prof,
                     double lsize, string type="TRADE_SIGNAL")
{
   if(!Enable_Telegram_Hoots && type != "TRADE_LOG") return;

   string acc_id  = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   string balance = DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2);
   string equity  = DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2);
   string rr      = "1:" + DoubleToString(Profit_Ratio / (Risk_Ratio > 0 ? Risk_Ratio : 1), 1);

   string payload = "{";
   payload += "\"account_id\":\"" + acc_id + "\",";
   payload += "\"balance\":\""    + balance + "\",";
   payload += "\"equity\":\""     + equity + "\",";
   payload += "\"type\":\""       + type + "\",";
   payload += "\"ticket\":\""     + IntegerToString(tkt) + "\",";
   payload += "\"symbol\":\""     + _Symbol + "\",";
   payload += "\"action\":\""     + act + "\",";
   payload += "\"price\":"        + DoubleToString(prc, _Digits) + ",";
   payload += "\"sl\":"           + DoubleToString(stop, _Digits) + ",";
   payload += "\"tp\":"           + DoubleToString(prof, _Digits) + ",";
   payload += "\"lot\":"          + DoubleToString(lsize, 2) + ",";
   payload += "\"risk\":\""       + DoubleToString(GetEffectiveRiskPercent(), 1) + "%\",";
   payload += "\"rr\":\""         + rr + "\",";
   payload += "\"session\":\""    + GetSessionName() + "\",";
   payload += "\"health\":"       + IntegerToString(g_health_score) + ",";
   payload += "\"time\":\""       + TimeToString(TimeCurrent(), TIME_MINUTES) + "\",";
   payload += "\"client\":\""     + g_client_name + "\"";
   payload += "}";

   char data[], result[];
   int len = StringToCharArray(payload, data, 0, WHOLE_ARRAY, CP_UTF8);
   if(len > 0) ArrayResize(data, len - 1);

   string res_headers;
   ResetLastError();
   int res = WebRequest("POST", MAKE_WEBHOOK_URL, "Content-Type: application/json\r\n",
                        10000, data, result, res_headers);

   if(res >= 200 && res <= 299)
      Print("☁️ Cloud: ", type, " sent (HTTP ", res, ")");
   else
      Print("❌ Cloud Error: HTTP ", res, " | Error: ", GetLastError());
}

void SendTradeLog(double profit, string symbol, long magic)
{
   string tt = (profit >= 0) ? "PROFIT" : "LOSS";
   SendTradeSignal(magic, tt, profit, 0, 0, 0, "TRADE_LOG");
}

//+------------------------------------------------------------------+
//| LICENCE VALIDATION                                                |
//+------------------------------------------------------------------+
bool ValidateLicence()
{
   if(MQLInfoInteger(MQL_TESTER) && Test_Bypass) return true;
   if(Server_URL == "") { Alert("🦉 No server URL configured."); return false; }

   g_instance_id = GetInstanceID();

   string url = Server_URL
              + "?type=validate"
              + "&key="      + Licence_Key
              + "&account="  + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN))
              + "&balance="  + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2)
              + "&equity="   + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2)
              + "&instance=" + g_instance_id
              + "&broker="   + AccountInfoString(ACCOUNT_COMPANY);

   char post_data[], result[];
   string res_headers;
   int res = WebRequest("GET", url, NULL, 15000, post_data, result, res_headers);

   if(res != 200)
   {
      Print("⚠️ Licence check HTTP: ", res);
      Alert("🦉 CONNECTION ERROR - HTTP " + IntegerToString(res));
      return false;
   }

   string response_body = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
   string clean = response_body;
   StringToLower(clean);

   if(StringFind(clean, "authorized") >= 0 || StringFind(clean, "uluka_master") >= 0)
   {
      PlaySound("hoot.wav");
      Alert("🦉 MASTER OWL: Authorized Successfully!");

      string parts[];
      StringSplit(response_body, '|', parts);

      if(ArraySize(parts) >= 2)
      {
         // Parse expiry
         string expiry_str = parts[1];
         if(ArraySize(parts) >= 3) g_client_name = parts[2];

         string exp_parts[];
         if(StringFind(expiry_str, "-") >= 0)       StringSplit(expiry_str, '-', exp_parts);
         else if(StringFind(expiry_str, "/") >= 0)  StringSplit(expiry_str, '/', exp_parts);

         if(ArraySize(exp_parts) == 3)
         {
            int d = (int)StringToInteger(exp_parts[0]);
            int m = (int)StringToInteger(exp_parts[1]);
            int y = (int)StringToInteger(exp_parts[2]);
           datetime expiry_date = StringToTime(StringFormat("%04d.%02d.%02d 23:59:59", y, m, d));
           MqlDateTime now_s;   TimeToStruct(TimeCurrent(), now_s);
            datetime today       = StringToTime(StringFormat("%04d.%02d.%02d 00:00:00",
                       now_s.year, now_s.mon, now_s.day));
            g_days_left          = (int)MathMax(0, (expiry_date - today) / 86400);
            Print("🔑 Expiry: ", TimeToString(expiry_date),
             " | Broker Today: ", TimeToString(today),
            " | Days: ", g_days_left);
         }
      }
      Alert("🦉 MASTER: Authorized | " + g_client_name + " | " +
            IntegerToString(g_days_left) + " days left");
      return true;
   }
   else
   {
      string raw = response_body;
      string reason = raw;
      StringToLower(raw);
      if(StringFind(raw, "not_found")       >= 0) reason = "Invalid key";
      else if(StringFind(raw, "expired")    >= 0) reason = "Licence expired";
      else if(StringFind(raw, "blacklisted")>= 0) reason = "Licence blacklisted";
      else if(StringFind(raw, "account_mismatch") >= 0) reason = "Wrong account (key locked to different account)";
      Alert("🦉 LICENCE REJECTED: " + reason);
      ExpertRemove();
      return false;
   }
}

string GetInstanceID()
{
   string ifile = "Uluka_Instance_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + ".dat";
   int fh = FileOpen(ifile, FILE_READ|FILE_TXT|FILE_COMMON);
   if(fh != INVALID_HANDLE)
   {
      string id = FileReadString(fh);
      FileClose(fh);
      if(StringLen(id) > 5) return id;
   }
   string new_id = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "_" +
                   IntegerToString(GetTickCount());
   fh = FileOpen(ifile, FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(fh != INVALID_HANDLE) { FileWriteString(fh, new_id); FileClose(fh); }
   return new_id;
}

string getClientIp() 
{ 
   return "0.0.0.0"; 
}

//+------------------------------------------------------------------+
//| TRADE CARD                                                        |
//+------------------------------------------------------------------+
/*string BuildTradeCardText(string header, ENUM_ORDER_TYPE type, double entry,
                          double sl, double tp, double lot)
{
   string dir = (type == ORDER_TYPE_BUY) ? "BUY 📈" : "SELL 📉";
   return "🦉 " + header + "\n"
        + "Asset: "  + _Symbol + "\n"
        + "Dir: "    + dir + "\n"
        + "Entry: "  + DoubleToString(entry, _Digits) + "\n"
        + "TP: "     + DoubleToString(tp, _Digits) + "\n"
        + "SL: "     + DoubleToString(sl, _Digits) + "\n"
        + "Risk: "   + DoubleToString(GetEffectiveRiskPercent(), 1) + "%\n"
        + "Strat: "  + GetStrategyName(Enable_SMC_Strategies ?
                       GetRecommendedStrategy(_Symbol, type) : STRATEGY_FARSIGHT) + "\n"
        + "Uluka Ultra";
}

bool CreateAndCaptureTradeCard(string &out_filename, string full_text,
                                ENUM_ORDER_TYPE type, double entry,
                                double sl, double tp, double lot)
{
   string prefix    = "TradeCard_";
   out_filename     = prefix + _Symbol + "_" + IntegerToString(TimeCurrent()) + ".png";

   ObjectsDeleteAll(0, prefix);

   string bg = prefix + "BG";
   ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE,  10);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE,  10);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE,      500);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE,      450);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR,    C'10,20,40');
   ObjectSetInteger(0, bg, OBJPROP_BORDER_COLOR, clrGold);
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_CORNER,     CORNER_LEFT_UPPER);

   CreateLabel(prefix+"Title", "🦉 ULUKA LIVE HOOT #" + IntegerToString(g_daily_trades_Count+1), 20, 20, clrDodgerBlue);
   ObjectSetInteger(0, prefix+"Title", OBJPROP_FONTSIZE, 14);

   CreateLabel(prefix+"HOOT", BuildTradeCardText(full_text, type, entry, sl, tp, lot), 20, 60, clrWhite);
   ObjectSetInteger(0, prefix+"HOOT", OBJPROP_FONTSIZE, 10);

   CreateLabel(prefix+"Session", "Session: " + GetSessionName() + " | Health: " +
               IntegerToString(g_health_score) + "/100", 20, 300, clrGold);
   ObjectSetInteger(0, prefix+"Session", OBJPROP_FONTSIZE, 9);

   CreateLabel(prefix+"Powered", "Powered by ULUKA ULTRA | SMART TRADE DECISSION", 20, 330, clrDodgerBlue);
   ObjectSetInteger(0, prefix+"Powered", OBJPROP_FONTSIZE, 9);

   CreateLabel(prefix+"Disc", DISCLAIMER, 20, 360, clrGray);
   ObjectSetInteger(0, prefix+"Disc", OBJPROP_FONTSIZE, 7);

   ChartRedraw(0); Sleep(1000);
   ChartRedraw(0); Sleep(2000);
   ChartRedraw(0); Sleep(3000);

   bool ok = ChartScreenShot(0, out_filename, 500, 450, ALIGN_LEFT);
   ObjectsDeleteAll(0, prefix);
   return ok && FileIsExist(out_filename);
}

//+------------------------------------------------------------------+
//| WEBHOOK UPLOAD                                                    |
//+------------------------------------------------------------------+
void UploadToWebhookBase64(string filename, string type)
{
   if(!FileIsExist(filename)) return; 

   long fsize = 0;
   int  retry = 0;
   while(fsize < 1000 && retry < 15) { Sleep(1000); fsize = FileSize(filename); retry++; }
   if(fsize < 1000) return;

   int handle = FileOpen(filename, FILE_READ|FILE_BIN|FILE_COMMON);
   if(handle == INVALID_HANDLE) return;

   uchar bytes[];
   ArrayResize(bytes, (int)fsize);
   int read = FileReadArray(handle, bytes);
   FileClose(handle);
   if(read != fsize) return;

   string b64     = Base64Encode(bytes);
   string payload = "{\"type\":\"" + type + "\","
                  + "\"filename\":\"" + filename + "\","
                  + "\"data\":\"" + b64 + "\"}";

   char data[], result[];
   StringToCharArray(payload, data);
   string res_headers;
   string headers = "Content-Type: application/json\r\n";
   int res = WebRequest("POST", MAKE_WEBHOOK_URL, headers, 60000, data, result, res_headers);

   if(res == 200 || res == 201) Print("✅ Webhook upload OK: ", type);
   else Print("❌ Webhook fail: ", type, " HTTP:", res);
}

string Base64Encode(uchar &data[])
{
   string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
   string out   = "";
   int len = ArraySize(data), i = 0;
   while(i < len)
   {
      uchar a = data[i++];
      uchar b = (i < len) ? data[i++] : 0;
      uchar c = (i < len) ? data[i++] : 0;
      out += chars[(a >> 2) & 0x3F];
      out += chars[((a << 4) | (b >> 4)) & 0x3F];
      out += (i > len + 1) ? '=' : chars[((b << 2) | (c >> 6)) & 0x3F];
      out += (i > len)     ? '=' : chars[c & 0x3F];
   }
   return out;
}

//+------------------------------------------------------------------+
//| LIVE HOOT TO APP                                                  |
//+------------------------------------------------------------------+
void SendLiveHootToApp(string symbol, string action, double price, string extra)
{
   string payload = "{" 
                  + "\"type\":\"LIVE HOOT\","
                  + "\"Asset\":\"" + symbol + "\","
                  + "\"Action\":\"" + action + "\","
                  + "\"Price\":" + DoubleToString(price, _Digits) + ","
                  + "\"Session\":\"" + GetSessionName() + "\","
                  + "\"Health\":" + IntegerToString(g_health_score) + ","
                  + "\"Extra\":\"" + extra + "\""
                  + "}";

   char data[], result[];
   StringToCharArray(payload, data, 0, WHOLE_ARRAY, CP_UTF8);
   ArrayResize(data, ArraySize(data) - 1);
   string headers = "Content-Type: application/json\r\n";
   WebRequest("POST", MAKE_WEBHOOK_URL, headers, 5000, data, result, headers);
}

//+------------------------------------------------------------------+
//| TELEGRAM PHOTO SENDER                                             |
//+------------------------------------------------------------------+
void SendTelegramPhoto(string chat_id, string filename, string caption)
{
   if(!FileIsExist(filename)) { Print("❌ Photo not found: ", filename); return; }

   int handle = FileOpen(filename, FILE_READ|FILE_BIN);
   if(handle == INVALID_HANDLE) return;

   uchar bytes[];  
   long fsize = FileSize(handle);
   ArrayResize(bytes, (int)fsize);
   FileReadArray(handle, bytes);
   FileClose(handle);

   string boundary = "----Boundary" + IntegerToString(GetTickCount());
   string headers  = "Content-Type: multipart/form-data; boundary=" + boundary;
   uchar  post_data[]; int pos = 0;

   AddFormField(post_data, pos, boundary, "chat_id", chat_id);
   AddFormField(post_data, pos, boundary, "caption", caption);

   string part = "--" + boundary + "\r\n"
               + "Content-Disposition: form-data; name=\"photo\"; filename=\"" + filename + "\"\r\n"
               + "Content-Type: image/png\r\n\r\n";
   uchar tmp[];
   StringToCharArray(part, tmp);
   int old = ArraySize(post_data);
   ArrayResize(post_data, old + ArraySize(tmp));
   ArrayCopy(post_data, tmp, old, 0, WHOLE_ARRAY);

   old = ArraySize(post_data);
   ArrayResize(post_data, old + (int)fsize);
   ArrayCopy(post_data, bytes, old, 0, (int)fsize);

   part = "\r\n--" + boundary + "--\r\n";
   StringToCharArray(part, tmp);
   old = ArraySize(post_data);
   ArrayResize(post_data, old + ArraySize(tmp));
   ArrayCopy(post_data, tmp, old, 0, WHOLE_ARRAY);

   char result[]; string res_headers;
   string url = "https://api.telegram.org/bot" + TG_API + "/sendPhoto";
   int res = WebRequest("POST", url, headers, 60000, post_data, result, res_headers);

   if(res == 200) Print("✅ Photo sent to ", chat_id);
   else Print("❌ Photo fail | HTTP ", res);
}

void AddFormField(uchar &post_data[], int &pos, string boundary, string name, string value)
{
   uchar tmp[];
   StringToCharArray("--" + boundary + "\r\n", tmp);
   ArrayCopy(post_data, tmp, pos, 0, WHOLE_ARRAY); pos += ArraySize(tmp);
   StringToCharArray("Content-Disposition: form-data; name=\"" + name + "\"\r\n\r\n", tmp);
   ArrayCopy(post_data, tmp, pos, 0, WHOLE_ARRAY); pos += ArraySize(tmp);
   StringToCharArray(value + "\r\n", tmp);
   ArrayCopy(post_data, tmp, pos, 0, WHOLE_ARRAY); pos += ArraySize(tmp);
}*/

//+------------------------------------------------------------------+
//| CUSTOM ALERT WITH COOLDOWN                                        |
//+------------------------------------------------------------------+
void Custom_Alert(string alert_key, string message)
{
   if(!Show_OnScreen_Alerts) return;

   static string   last_keys[];
   static datetime last_times[];
   static int      total_tracked = 0;

   int found = -1;
   for(int i = 0; i < total_tracked; i++)
      if(last_keys[i] == alert_key) { found = i; break; }

   if(found == -1)
   {
      total_tracked++;
      ArrayResize(last_keys,  total_tracked);
      ArrayResize(last_times, total_tracked);
      found = total_tracked - 1;
      last_keys[found]  = alert_key;
      last_times[found] = 0;
   }

   if(TimeCurrent() - last_times[found] >= Alert_Cooldown_Seconds)
   {
      Alert("🦉 ULUKA: " + message);
      Print("🦉 [ALERT]: ", message);
      last_times[found] = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| URL ENCODE                                                        |
//+------------------------------------------------------------------+
string UrlEncode(string text)
{
   string out = "";
   uchar  arr[];
   StringToCharArray(text, arr);
   
   // MQL5 safe characters list
   string safe = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";
   
   // StringToCharArray adds a null terminator at the end, so we use Size - 1
   int total = ArraySize(arr);
   if(total > 0) total--; 

   for(int i = 0; i < total; i++)
   {
      // Char ko string mein convert karne ka sahi MQL5 tarika
      string c = StringFormat("%c", arr[i]);
      
      if(StringFind(safe, c) >= 0)
         out += c;
      else
         out += StringFormat("%%%02X", arr[i]);
   }
   return out;
}

string EscapeMarkdownV2(string text)
{
   // Only used if switching to MarkdownV2 parse mode later
   string reserved = "_*[]()~`>#+-=|{}.!";
   string escaped  = "";
   for(int i = 0; i < StringLen(text); i++)
   {
      string c = StringSubstr(text, i, 1);
      if(c == "\\") { escaped += "\\\\"; continue; }
      bool isR = false;
      for(int j = 0; j < StringLen(reserved); j++)
         if(c == StringSubstr(reserved, j, 1)) { isR = true; break; }
      if(isR) escaped += "\\";
      escaped += c;
   }
   return escaped;
}

//+------------------------------------------------------------------+
//| POSITIONS BY MAGIC (kept in MQ5 for backward compat)             |
//+------------------------------------------------------------------+
int PositionsTotalByMagicAll()
{
   return PositionsTotalByMagicAll(Magic_Number);
}

// Using MQH version with symbol param for main logic

//+----------------------------------------------------------------------------------------------+
//| Below Listed code blocks are temporarly commneted out, as they might be used in future //    |
//+----------------------------------------------------------------------------------------------+

// TRADE CARD, WEBHOOK UPLOAD LIVE HOOT TO APP, TELEGRAM PHOTO SENDER //
// CHECK LINE 239 AND 242 FOR GLOBAL DECLARATION, 663,| 1220 TO 1250,| 
