@IsTest
public class TemperatureConverterTest {
    // Test method for converting Celsius to Fahrenheit
    @IsTest
    static void testCelsiusToFahrenheit() {
        Double celsius = 0; // Freezing point of water
        Double expectedFahrenheit = 32; // Freezing point of water in Fahrenheit
        Double result = TemperatureConverter.celsiusToFahrenheit(celsius);
        System.assertEquals(expectedFahrenheit, result, '0 Celsius should be 32 Fahrenheit');
    }
}