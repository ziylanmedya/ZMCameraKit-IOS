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

### Tekli ürün deneyimi için: 
`let singleLensView = ZMCKit.createSingleProductView(
    snapAPIToken: "YOUR_SNAP_API_TOKEN",
    partnerGroupId: "YOUR_GROUP_ID",
    lensId: "YOUR_LENS_ID"
)`

### Çoklu ürün deneyimi için:
`let multiLensView = ZMCKit.createMultiProductView(
    snapAPIToken: "YOUR_SNAP_API_TOKEN",
    partnerGroupId: "YOUR_GROUP_ID"
)`

Her iki deneyim için de ilgili View oluşturulduktan sonra, eklenilmek istenen view'a
`addSubview()` metodu ile eklenmelidir.

### Anlık gösterilen lens bilgisine ulaşmak için:
`ZMCKit.onLensChange { lensId in
    if let lensId = lensId {
        print("Current lens ID: \(lensId)")
    }
}` bu callback fonksiyonun ek olarak, 
`if let currentLensId = ZMCKit.currentLensId {
    print("Active lens: \(currentLensId)")
}` şeklinde de anlık lens bilgisine ulaşabilirsiniz.

### Temizlik
Bu işlem için aşağıdaki iki fonksiyonu da kullanabilirsiniz: 
`
cameraView.cleanup()
cameraView.removeFromSuperview() // Bu işlem otomatik olarak cleanup fonksiyonunu da çağırır
`

