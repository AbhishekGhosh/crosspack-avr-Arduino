#include <Arduino.h>

enum {
  BLINK_DELAY_ON = 100,
  BLINK_DELAY_OFF = 900
};

#define LED_PIN 13 

void main(void)
{
  init();

  while(1){
    digitalWrite(LED_PIN, HIGH);
    _delay_ms(BLINK_DELAY_ON);
    digitalWrite(LED_PIN, LOW);
    _delay_ms(BLINK_DELAY_OFF);
  }
}
