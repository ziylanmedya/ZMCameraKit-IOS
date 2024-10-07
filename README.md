# ZMCameraKit

## ZiylanMedyaCameraKit

### SPM: https://github.com/ziylanmedya/ZMCameraKit

### Info.plist
  - Queried URL Schemes -> snapchat
  - Privacy - Camera Usage Description
  - Privacy - Photo Library Usage Description
  - Privacy - Microphone Usage Description

### XCode 16 Update:
- Proje targeti seçilip Build Settings kısmında sol üstten `+` tıklanarak `Add-User Defined Setting` seçilmelidir. Açılan alana `STRIP_BITCODE_FROM_COPIED_FILES` yazılmalı ve tüm değerler `NO` olarak set edilmelidir.

## Nasıl Kullanılır?

ZiylanMedyaCameraKit'in kulllanılacğı yerlerde;

`import ZMCKit` şeklinde paketin import edilmesi gerekmektedir.

Başlatmak için: `ZMCKit.initialize()`
### Ayağında dene deneyimi için: 
`ZMCKit.presentSplashExperience(from: self, snapAPIToken: snapAPIToken, partnerGroupId: partnerGroupId)`
Not: Bu test versiyonu için gerekli token değerleri sizlerle paylaşılacaktır.
