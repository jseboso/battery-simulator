#include "batt.h"


// int set_batt_from_ports(batt_t* batt) {
//     if (BATT_VOLTAGE_PORT < 0) {
//         return 1;
//     }
//     batt->mlvolts = BATT_VOLTAGE_PORT >> 1;
//     batt->percent = (batt->mlvolts - 3000) >> 3;
//     if (batt->mlvolts < 3000) {
//         batt->percent = 0;
//     }
//     if (batt->mlvolts > 3800) {
//         batt->percent = 100;
//     }
//     batt->mode = (BATT_STATUS_PORT >> 4) & 1;
//     if (batt->mode == 0) {
//         batt->mode = 2;
//     }
//     return 0;
// }

// int set_display_from_batt(batt_t batt, int* display) {
//     int tempDisplay = 0;
//     int bitMasks[10] = {0};
//     bitMasks[0] = 0b0111111;
//     bitMasks[1] = 0b0000110;
//     bitMasks[2] = 0b1011011;
//     bitMasks[3] = 0b1001111;
//     bitMasks[4] = 0b1100110;
//     bitMasks[5] = 0b1101101;
//     bitMasks[6] = 0b1111101;
//     bitMasks[7] = 0b0000111;
//     bitMasks[8] = 0b1111111;
//     bitMasks[9] = 0b1101111;
//     // fill up battery
//     if (batt.percent >= 5) {tempDisplay |= (0b1 << 24);}
//     if (batt.percent >= 30) {tempDisplay |= (0b1 << 25);}
//     if (batt.percent >= 50) {tempDisplay |= (0b1 << 26);}
//     if (batt.percent >= 70) {tempDisplay |= (0b1 << 27);}
//     if (batt.percent >= 90) {tempDisplay |= (0b1 << 28);}

//     if (batt.mode == 1) {
//         // percent
//         int rightDigit = batt.percent % 10;
//         int middleDigit = (batt.percent / 10) % 10;
//         int leftDigit = (batt.percent / 100) % 10;
//         if (batt.percent >= 100) {
//             tempDisplay |= (bitMasks[leftDigit] << 17);
//         }
//         if (batt.percent >= 10) {
//             tempDisplay |= (bitMasks[middleDigit] << 10);
//         }
//         tempDisplay |= (bitMasks[rightDigit] << 3);
//         tempDisplay |= (0b001 << 0);
//     } else if (batt.mode == 2) {
//         // volts
//         int rightDigit = ((batt.mlvolts % 100) + 5) / 10;
//         int middleDigit = (batt.mlvolts / 100) % 10;
//         int leftDigit = (batt.mlvolts / 1000) % 10;
//         tempDisplay |= (bitMasks[leftDigit] << 17);
//         tempDisplay |= (bitMasks[middleDigit] << 10);
//         tempDisplay |= (bitMasks[rightDigit] << 3);
//         tempDisplay |= (0b110 << 0);
//     } else {
//         return 1;
//     }
//     *display = tempDisplay;
//     return 0;
// }

// int batt_update() {
//     batt_t newBatt;
//     batt_t* battPointer = &newBatt;
//     if (set_batt_from_ports(battPointer) != 0) {
//         return 1;
//     }
//     int* changeDisplay = &BATT_DISPLAY_PORT;
//     set_display_from_batt(newBatt, changeDisplay);
//     return 0;
// }