/*!
 * @file readVoltage.ino
 * @brief connect ADS1115 I2C interface with your board (please reference board compatibility)
 * @n The voltage value read by A0 A1 A2 A3 is printed through the serial port.
 *
 * @copyright   Copyright (c) 2010 DFRobot Co.Ltd (http://www.dfrobot.com)
 * @license     The MIT License (MIT)
 * @author [luoyufeng](yufeng.luo@dfrobot.com),
 * @version  V1.0
 * @date  2019-06-19
 * @url https://github.com/DFRobot/DFRobot_ADS1115
 */


#include <Wire.h>
#include <DFRobot_ADS1115.h>

volatile uint8_t adc_sample_start =0;
hw_timer_t * timer = NULL;
// void ARDUINO_ISR_ATTR onTimer();

/* void ARDUINO_ISR_ATTR onTimer(){

   adc_sample_start =1;

}*/



DFRobot_ADS1115 ads(&Wire);

void setup(void) 
{
    Serial.begin(115200);
    ads.setAddr_ADS1115(ADS1115_IIC_ADDRESS1);   // 0x48
   // ads.setGain(eGAIN_SIXTEEN);   // 2/3x gain
    ads.setGain(eGAIN_SIXTEEN);   // 2/3x gain
    ads.setMode(eMODE_SINGLE);       // single-shot mode
    ads.setRate(eRATE_860);          // 128SPS (default)
    ads.setOSMode(eOSMODE_SINGLE);   // Set to start a single-conversion
    ads.init();
}

void loop(void) 
{
  static unsigned int t=0;
  int16_t adc0;
  int16_t mmHg;
        adc0 = ads.readVoltage(4);
        Serial.print(t);
        Serial.print(" ");
        Serial.println(adc0);
        t=t+5;
        delay(3);
}
