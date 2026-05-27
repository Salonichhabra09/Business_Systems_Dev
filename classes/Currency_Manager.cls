public class Currency_Manager 
{

public static CurrencyType[] getAllCurrencyTypes()
{
    //Fetch the List of Currencies
    CurrencyType[] currencyTypes = [SELECT IsoCode, ConversionRate FROM CurrencyType ORDER BY IsoCode];
    return currencyTypes;
}

public static CurrencyType getCurrencyType(String currencyIsoCode, CurrencyType[] currencyTypes)
{
    CurrencyType resultCurrencyType = new CurrencyType();
    for(Integer i=0;i<currencyTypes.size();i++)
    {
        if(currencyTypes[i].IsoCode == currencyIsoCode)
        {
            resultCurrencyType = currencyTypes[i];
            break;
        }
    }
    return resultCurrencyType;
}

public static Double getCurrencyConversionRate(String fromCurrencyIsoCode, String toCurrencyIsoCode)
{
    CurrencyType fromCurrencyType = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode= :fromCurrencyIsoCode Limit 1];
    CurrencyType toCurrencyType = [SELECT ConversionRate FROM CurrencyType WHERE IsoCode= :toCurrencyIsoCode Limit 1];
    return toCurrencyType.ConversionRate/fromCurrencyType.ConversionRate;
}




}