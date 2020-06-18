# Music Organizer

### På grunn av CocoaPods må man åpne Exam Music Player.xcworkspace og ikke xcodeproj.

Da jeg lagde dette prosjektet fulgte jeg eksamensskissene veldig nøye. Appen min ser derfor veldig lik ut som skissene i oppgavesettet. Så vidt jeg kan se har jeg implementeret alle kravene fra oppgaven.

## Oppsett

Jeg startet med å sette opp en Tab Bar Controller som er root Controlleren. Fra denne går det ut tre navigation controllers, en til hver tab: Top, Search og Favorites. Dette gjør det lett å navigere rundt. Både Top og Search controllers kan navigere videre til detail view. Her er bildet på toppen som fyller sin aspect ratio og et table view med låter under.

På top view kan man bruke en segment control i navigation bar til å bytte mellom collection view og tableview. Jeg har valgt å lage extensions for tableview og collectionview her for å gjøre koden mer oversiktlig.

Jeg hadde tenkt å la helle viewet scrolle og implementerte først en scrollview med et nested view og et nested tableview. Dette fungerte helt ok men av og til kunne scrolling oppføre seg rart. Jeg så deretter her "https://developer.apple.com/documentation/uikit/uiwebview" hvor det står "You should not embed UIWebView or UITableView objects in UIScrollView objects." Jeg valgte derfor å la toppen av viewet vøre statisk og scrolle i tableview. Men jeg synes løsningen jeg har nå fungerer bra bortsett fra at tableviewet kan bli litt smått på mindre enheter.

På Favorite View Controller henter den inn sangene man har lagt inn i Core Data. Her har jeg benyttet meg av tableview sine metoder for å omorganisere og slette rader etter man klikker på "Edit" og låtene blir da også slettet fra core data. På bunnen vil man se alle recommendations med "type: music" basert på de artistene man har i favoritter.

I search valgte jeg at man må klikke på search-knappen på tastaturet eller på enter om man kjører simulator når man skal finne album. Dette er fordi jeg ikke ville kjøre requests hele tiden om den oppdaterte seg i real-time. Når man søker kjører den ett request til "album search" og ett til "all albums by artist search" slik at man kan søke på enten album eller artist.

## Cocoapods Frameworks

Jeg har brukt to CocoaPods Framework i dette prosjektet. En ulempe med Cocoapods var at det var litt uklart akkurat hvordan det skulle settes opp med podfile og installeres, samt hvordan "pods" skulle installeres. Det gjør også om på hele prosjektstrukturen når den installerer nye frameworks. Men alt i alt mener jeg det er greit å bruke når man forsåtr det, og det gjør livet til en swift-programmerer mye lettere. Jeg har ikke prøvd Swift Package Manager enda men jeg tror at nå som det blir flere oppdateringer på det vil det ta over mye av det ansvaret cocoapods har nå.

### Alamofire

Alamofire har blitt brukt til alle API request i prosjektet. Jeg mener det gjør at det oftere blir en mer forståelig kode med Alamofire enn ved å bruke URLSession. Alamofire er tross alt bygd på toppen av URLSession for å prøve å forbedre det. Jeg har blant annet benyttet meg av det til å enkelt legge til parametere til mine queries til API-et.

Det høres ut som at URLSession har blitt veldig bra i det siste men i min opplevelse virker som at Alamofire ofte kan gjøre det samme med mye færre linjer kode i tillegg til å være mer forståelig.

### Kingfisher

Jeg har brukt Kingfisher for å vise bilder. Dette er fordi jeg så at det var ganske komplisert å fylle et imageView med et bilde fra en url på nettet. Jeg prøvde først med SDWebImage som er et veldig likt framework. Dette fikk jeg derimot til å fungere med alle andre bilder enn dem fra theaudiodb. Da lastet jeg ned Kingfisher istedenfor og dette virket veldig greit. Jeg trengte bare en linje kode for å få lagt inn et bilde
fra URL.

Utifra hva jeg har googlet meg frem til så hadde jeg trengt veldig mye komplisert rotete kode kun for å legge inn et bilde fra en url om jeg ikke hadde benyttet et framework som Kingfisher.

## Kilder

For å bruke Alamofire og URL requests:
https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#using-alamofire

For å legge til og hente ut fra Core Data har jeg lært det meste her:
https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CoreData/index.html#//apple_ref/doc/uid/TP40001075-CH2-SW1

For å lære om å bruke Codable protokollen lærte jeg mye av denne guiden:
https://medium.com/flawless-app-stories/lets-parse-the-json-like-a-boss-with-swift-codable-protocol-3d4c4290c104

Jeg lagde en alert som minner om en toast fra andre språk. Brukte en del kode fra: https://medium.com/@rushikeshT/displaying-simple-toast-in-ios-swift-57014cbb9ffa
