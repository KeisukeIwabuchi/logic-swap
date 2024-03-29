#property version   "1.00"
#property strict
#property indicator_chart_window


#include <Lock.mqh>
#include <Controls\Label.mqh>


extern double Lots = 0.1;
extern int FontSize = 14;


CLabel *Spread;
CLabel *Buy;
CLabel *Sell;


int OnInit()
{
    string name;
    int x = 10;
    int y = 10;
    
    name = "logic-swap-spread";
    ObjectDelete(0, name);
    Spread = new CLabel();
    Spread.Create(0, name, 0, x, y, 100, 100);
    Spread.Color(clrMagenta);
    Spread.Font("メイリオ");
    Spread.FontSize(FontSize);
    Spread.Text("");
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    y += 10 + FontSize;

    name = "logic-swap-buy";
    ObjectDelete(0, name);
    Buy = new CLabel();
    Buy.Create(0, name, 0, x, y, 100, 100);
    Buy.Color(clrBlue);
    Buy.Font("メイリオ");
    Buy.FontSize(FontSize);
    Buy.Text("");
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    y += 10 + FontSize;
    
    name = "logic-swap-sell";
    ObjectDelete(0, name);
    Sell = new CLabel();
    Sell.Create(0, name, 0, x, y, 100, 100);
    Sell.Color(clrRed);
    Sell.Font("メイリオ");
    Sell.FontSize(FontSize);
    Sell.Text("");
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
    
    if (Lock()) {
        Spread.Text(GetSpreadText());
        Buy.Text(GetBuyText());
        Sell.Text(GetSellText());
    }
    return(INIT_SUCCEEDED);
}


void OnDeinit(const int reason)
{
    delete(Spread);
    delete(Buy);
    delete(Sell);

    Comment("");
}


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    if (!Lock()) {
        return(0);
    }
    
    Spread.Text(GetSpreadText());
    Buy.Text(GetBuyText());
    Sell.Text(GetSellText());
    
    return(rates_total);
}


string GetSpreadText()
{
    double mult = (_Digits == 3 || _Digits == 5) ? 10.0 : 1.0;
    
    return(DoubleToString(Lots, 2) +
        "Lot spread:" +
        DoubleToString(MarketInfo(_Symbol, MODE_SPREAD) / mult, 1) +
        "pips");
}


string GetBuyText()
{
    return(GetSwapText("Buy", SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG)));
}


string GetSellText()
{
    return(GetSwapText("Sell", SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT)));
}


string GetSwapText(string type, double swap)
{
    double swap_jpy = Lots * swap * GetRate();
    return(type + " swap:" +
        IntegerToString((int)MathFloor(swap)) +
        "円／日 " +
        IntegerToString((int)MathFloor(swap) * 360) +
        "円／年");
}


double GetRate()
{
    string symbol = StringSubstr(_Symbol, 0, 3) + "JPY";
    if (StringLen(_Symbol) > 6) {
        symbol += StringSubstr(_Symbol, 6, StringLen(_Symbol) - 6);
    }

    return(iClose(symbol, 0, 0));
}
