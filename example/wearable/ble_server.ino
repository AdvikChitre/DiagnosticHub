#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// BLE Configuration
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// Sawtooth Wave Constants
const long UPDATE_INTERVAL = 100;    // ms
const float SAWTOOTH_PERIOD = 4000;  // full wave cycle cycle
const float SAWTOOTH_MIN = -10.0;
const float SAWTOOTH_MAX = 10.0;

BLECharacteristic *pCharacteristic;  // Global characteristic pointer

float getSawtoothValue(unsigned long currentMillis) {
  float phase = fmod(currentMillis, SAWTOOTH_PERIOD) / SAWTOOTH_PERIOD;
  return SAWTOOTH_MIN + (SAWTOOTH_MAX - SAWTOOTH_MIN) * phase;
}

void setup() {
  Serial.begin(115200);
  Serial.println("Starting BLE Sawtooth Generator!");

  // Initialize BLE
  BLEDevice::init("BLE Sawtooth Generator");
  BLEServer *pServer = BLEDevice::createServer();
  BLEService *pService = pServer->createService(SERVICE_UUID);
  
  pCharacteristic = pService->createCharacteristic(
    CHARACTERISTIC_UUID,
    BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

  // Set initial value
  float initialValue = getSawtoothValue(0);
  char valueStr[10];
  dtostrf(initialValue, 6, 2, valueStr);
  pCharacteristic->setValue(valueStr);

  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  
  Serial.println("BLE Ready - Sawtooth Wave Active!");
  Serial.println("Wave Parameters:");
  Serial.printf(" - Range: %.1f to %.1f\n", SAWTOOTH_MIN, SAWTOOTH_MAX);
  Serial.printf(" - Period: %.1fs\n", SAWTOOTH_PERIOD/1000);
  Serial.printf(" - Update Interval: %dms\n", UPDATE_INTERVAL);
}

void loop() {
  static unsigned long previousMillis = 0;
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= UPDATE_INTERVAL) {
    previousMillis = currentMillis;
    
    // Get current sawtooth value
    float value = getSawtoothValue(currentMillis);
    
    // Convert to string and update BLE
    char valueStr[10];
    dtostrf(value, 6, 2, valueStr);
    pCharacteristic->setValue(valueStr);
    
    // Optional serial output
    Serial.print("Current Value: ");
    Serial.println(valueStr);
  }
}