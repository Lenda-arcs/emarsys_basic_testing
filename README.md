# tchibo_emarsys_testing

A very simple Flutter app that demonstrates how Emarsys SDK fails to throw an exception when
`Emarsys.push.pushSendingEnabled` is called when private DNS is enabled on an Android devices'

## Prerequisites

1. Add your own google-services.json file to the android/app folder

## Steps to reproduce

1. On Android go to System Settings > Network & Internet > Private DNS
2. Enter the Adguard DNS server: `dns.adguard.com`
3. When calling await Emarsys.push.pushSendingEnabled(isEnabled); the Emarsys SDK fails without an exception.