# QRding

QRding is a simple self-hosted QR code generator. It includes templates for creating QR codes for sharing WiFi credentials, contact cards and text or links. In the long-term the goal is to build an automation system around QR codes which allows you to trigger custom actions, track actions or habits and send notifications when a scan event is not triggered.

## Features

* QR code for sharing WiFi credentials
* QR code for sharing contact cards
* QR code for adding events to calendars
* QR code for generic link sharing and text
* Customize size of QR code image
* Customize color of QR codes

## Installation

QRding is available as a docker image and can be deployed with the docker-compose provided below.

````compose
version: '3.8'

services:
  qrding:
    image: ghcr.io/rishikanthc/qrding:v0.1.0
    container_name: qrding
    ports:
      - "3000:3000"
    restart: unless-stopped
````

## Cool ideas for using QR codes

I highly recommend getting a label maker to print out QR codes and stick them on specific locations or objects depending on the type of usage.

1. **Connect to WiFi**  
   Encode SSID, security type, and password so scanning immediately joins the network (no manual typing).
1. **Add a Contact (vCard)**  
   Embed a full “virtual business card” (name, phone, email, address). Scanning prompts “Add to Contacts.”
1. **Compose an SMS**  
   Encode SMSTO:+15551234567:Your message here so the user’s messaging app opens with the recipient and body pre-filled.
1. **Dial a Phone Number**  
   Embed an VEVENT (title, start/end, location) so the calendar app offers to add it straight into the user’s schedule.
1. **Send an Email**
   Use MATMSG:TO:you@example.com;SUB:Subject here;BODY:Email body;; or MAILTO: syntax to open the email composer with fields pre-filled.
1. **Geo-Coordinates / Map Location**  
   Encode geo:37.786971,-122.399677 so the mapping app opens at those coordinates.
1. **App Deep-Link or Custom URI Scheme**  
   e.g. myapp://product/1234 launches a specific view inside an installed app (if it supports that URI scheme), or falls back to a URL.
1. **Bluetooth Pairing**  
   Some devices support BLUETOOTH:MAC-address;PIN:1234; → triggers pairing dialogue for headsets or smart devices.
1. **Text-Only Payload**  
   Plain text that the user can copy to clipboard—ideal for coupons, short instructions, or secret messages, without any network call.

# Roadmap for potential advanced use cases

* Save and browse generated QR codes
* Automations via webhooks and integration with other apps like Home Assistant, Ntfy, discord.
  * Track events/habits and trigger notifications - For eg. QR code stuck on medicine cabinet. Scan everytime you take meds. If the code hasn’t been scanned before a pre-set deadline, send a reminder/notification.
  * Trigger specific evens when code is scanned
    * **Smart Home Scene Triggers**: Place QR stickers around the house. Scanning the “Movie Night” code dims lights, closes blinds, and fires up the home theater. Scan “Good Morning” in your bedroom to raise shades, start the coffee maker, and read you the day’s weather.
    * **Equipment & Tool Checkout**: In a makerspace or home workshop, each tool has its own QR. Scanning when you borrow it logs you as the current user. If you haven’t returned (i.e. scanned it back) within your allotted time, an automated reminder pings you.
    * **Plant & Pet Care Scheduling**: QR on each plant’s pot or pet’s food bin: scan to log watering or feeding. If no scan happens after the plant’s ideal watering interval (e.g. 7 days) or pet’s mealtime window, your smart home assistant reminds you.
    * **On-Demand How-To Guides**: Affix QR codes on appliances or furniture. Scanning the code launches the PDF manual.
    * **Vehicle & Machinery Maintenance Logs**: Under the hood or on factory equipment: scan QR to instantly log an oil change, safety inspection, or filter replacement. The system then auto-schedules the next service reminder based on mileage or hours run.
    * **Inventory management**: QR codes on pantry items connect to your home-inventory app. Scanning the last bag of flour or coffee bean container both logs the “out-of-stock” event and fires off an order to your preferred grocery service.

# Contributing

Contributions are most welcome!
If you have any cool ideas / use cases / request for templates / any issues please open an
issue in the issue tracker and I’ll get back to you as soon as possible. I’m looking for ideas to take this project further to build automation pipelines based on QR codes.
Please follow these steps to contribute to development:

1. Fork the repository.
1. Create a feature branch (git checkout -b feature/my-cool-feature).
1. Commit your changes (git commit -m “Add awesome feature”).
1. Push to your branch (git push origin feature/my-cool-feature).
1. Open a Pull Request, describing the change and any setup steps.

# License

This project is licensed under the MIT License. See LICENSE for details.

