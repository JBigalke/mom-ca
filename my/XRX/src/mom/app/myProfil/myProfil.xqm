xquery version "3.0";
(:~
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
:)

module namespace myProfil = "http://www.monasterium.net/NS/myProfil";


import module namespace xrx="http://www.monasterium.net/NS/xrx" at "xmldb:exist:///db/XRX.live/mom/app/xrx/xrx.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf" at "xmldb:exist:///db/XRX.live/mom/app/xrx/conf.xqm";
import module namespace mycollection="http://www.monasterium.net/NS/mycollection" at "../collection/mycollection.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata" at "../metadata/metadata.xqm";
import module namespace user="http://www.monasterium.net/NS/user" at "../user/user.xqm";
    
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace cei="http://www.monasterium.net/NS/cei";


declare function myProfil:getshowpublishtwitterbutton()
{
let $xml := user:document($xrx:user-id) (: User.xml des angemeldeten Nutzers :)
let $result := $xml//xrx:twitter/xrx:showpublishtwitterbutton (: Wert der in <showpublishtwitterbutton angegeben ist, kann true or false annehmen. :)
return $result (: rückgabe des wertes :)
};

(:
 *   @param: $collection =  collections aus xrx.user/[user]/metadata.mycollections
:)
declare function myProfil:sortCollections($collections) as element() {
  let $xml := 
      <xrx:collections  xmlns:xrx='http://www.monasterium.net/NS/xrx'>      (: enthält ALLE collections die der angemeldete User erstellt hat :)
              <xrx:publiccollections>                                       (: enthält alle public collections die der User erstellt hat :)
         {for $collection in myProfil:getAllPublicCollections()             (: Für jede public collection die von myProfil:getAllPublicCollections() übergeben werden :)  
           let $entry := root($collection)//atom:id                         (: .. nehme <atom:id> :)
           let $title := root($collection)//cei:title                       (: .. nehme <cei:title> :)
           let $hasprivate := myProfil:PublicCollectionHasPrivateVersion($entry)                 (: ..teste ob es eine PrivateVersion dieser Collection gibt :)
           let $isactual := if($hasprivate = 'true') then myProfil:PublicCollectionIsActual($collection)    (: .. teste ob die Private oder Public version neuer ist :)
            else 'true'
           return <xrx:collection hasprivateversion='{$hasprivate}'>                (: angaben zu einer collection, hasprivateversion kann true oder false annehmen. :)                 
                    <xrx:entry actual='{$isactual}'>{$entry/text()}</xrx:entry>     (: Atom:id der collection, actual kann werte true oder false annehmen.:)
                    <xrx:title>{$title/text()}</xrx:title>                          (: Titel der collection :)
                  </xrx:collection>            
             }            
        </xrx:publiccollections>
        <xrx:privatecollections>        (: enthält alle private collections des angemeldeten Users :)
            {for $collection in $collections//xrx:sharing[xrx:visibility ='private']        (: für jede collection die als parameter übergeben wurden. teste ob es eine public version gibt. :)
             let $entry := root($collection)//atom:id       (: .. nehme <atom:id> :)
             let $title := root($collection)//cei:title     (: .. nehme <cei:title> :)
             return <xrx:collection> (:speicher informatioen der collection :)
                      <xrx:entry>{$entry/text()}</xrx:entry>
                      <xrx:title>{$title/text()}</xrx:title> 
                    </xrx:collection>
                          }
        </xrx:privatecollections>
       </xrx:collections>
    
       return $xml
  };
  
(: @param: $friendS =<xrx:friends><xrx:friend>
                        <xrx:account></xrx:account>
                        <xrx:status></xrx:status>
                       </xrx:friend>
                       ...
                     </xrx:friends>
:)
  declare function myProfil:createFriendlist($friends){
    let $xml := <table>
                {for $friend in $friends/xrx:friend                                     (: für jeden $fried-node in friends :)
                 let $requester-doc :=user:document-by-uuid($friend/xrx:account)        (: suche das zu diesem nutzer zugehörige user-document :)
                 let $status := $friend//xrx:status                                     (: .. nehme den status :)
                    let $test := 
                    if ($status="request") then                                         (: wenn der status den wert "request hat" :)
                     <tr>                                                               (: ... erstelle eine tabellenzeile :)
                        <td>{$requester-doc//xrx:name}</td>                             (: ... die den Namen des friends beinhaltet :)
                        <td><a href='javascript:createConfirmFriendshipPopup("{$requester-doc//xrx:name}","{$friend//xrx:account}")'>confirm</a></td>       (:.. erstelle eine Link um die freundschaft zu bestätigen:)
                        <td><a href='javascript:createIgnoreFriendshipPopup("{$requester-doc//xrx:name}","{$friend//xrx:account}")'>ignore</a></td></tr>    (:.. erstelle einen Link um die freundschaftsanfrage zu ignorieren :)
                     else if($status="friendship") then <tr><td>{$requester-doc//xrx:name}</td></tr>   (: Ist der Status= friendship erstelle einfach nur eine Tabellenzeile mit dem Namen des friendsd :) 
                     else  if($status="ignored") then ()       (: Ist der Status = ignored dann erstelle gar nichts :) 
                     else()                                    (: ist der Status irgendwas anderes ignoriere diesen eintrag auch :)
                         return $test}            
                     </table>  
    return $xml
  };  
  

 (: @param: $elements =  <xrx:publiccollections>
                         <xrx:collection hasprivateversion >
                            <xrx:entry actual ></xrx:entry>
                            <xrx:title></xrx:title>
                         </xrx:collection>
                         ...
                     </xrx:publiccollections>
 :)
declare function myProfil:buildPublicCollectionList($elements){
  let $list := <table>                              <!-- erstelle eine Tabelle -->
   {for $element in $elements/xrx:collection        (: ..für jedes element in elements :)
    let $part :=                                           
     if($element/@hasprivateversion ='true')        (: ..teste ob das attribute hasprivateversion = true ist :)
      then <tr><td><a href="{myProfil:createLink($element//xrx:entry, 'collection')}">{$element//xrx:title}</a></td>    <!-- ist dies so, dann erstelle einen Link auf die Publizierte Collection -->
              <td><a href="{myProfil:createLink($element//xrx:entry, 'my-collection')}">{if($element//xrx:entry/@actual ='true') then '(private Version)' else '(private Version)*'}</a></td> <!-- Teste dann welche Version aktueller ist. Erstelle einen Link zur Private Collection, markiere ihn mit einem Link wenn die Private version aktueller als die Public version ist -->
           </tr>
      else <tr><td><a href="{myProfil:createLink($element//xrx:entry, 'collection')}">{$element//xrx:title}</a></td></tr> (: Gibt es zu der Public-Version keine Private version, dann erstelle einfach nur einen Link zur Public Collection :)
      return $part}
      </table>
         return $list (: Gebe die so erstellte Tabelle zurück :)
  };
 (: @param elements = <xrx:privatecollections>
                         <xrx:collection>
                           <xrx:entry></xrx:entry>
                           <xrx:title></xrx:title>
                         </xrx:collection>
                                            ...
                       </xrx:privatecollections> :) 
declare function myProfil:buildPrivateCollectionList($elements){  
  let $list := <table> <!-- Erstelle eine Tabelle -->
   {for $element in $elements/xrx:collection (: für jedes element in elements :)
    let $part :=  <tr><td><a href="{myProfil:createLink($element//xrx:entry, 'my-collection')}">{$element//xrx:title}</a></td></tr> (: Erstelle eine neue Tabellenzelle die ein Link zur  Tabelle enthält :)
      return $part
      }
</table>
   return $list
  };
  
  
 (: @param $entry =         <xrx:privatecollections>
                                            <xrx:collection>
                                                <xrx:entry></xrx:entry>
                                                <xrx:title></xrx:title>
                                            </xrx:collection>
                                            ...
                                       </xrx:privatecollections>
     @param $kind = art der collection, z.b my-collection oder collection :) 
declare function myProfil:createLink($entry, $kind){
 let $collection-id := metadata:objectid($entry) (: Erstelle aus <xrx:entry> eine objectid :)
 let $link := concat(conf:param('request-root'),$collection-id,'/',$kind) (:erstelle einen Link aus der Objektid und der collectionart. :)
 return $link
};
  

(: @param $collection =  Eine collection aus metadata.mycollection :)
declare function myProfil:PublicCollectionIsActual($collection){ 
let $collection-id :=$collection//atom:id (: .. hol die <atom:id> :)
let $private-collection := metadata:base-collection('mycollection', 'private')//atom:entry[atom:id=$collection-id] (: hole dir mit hilfe der atom:id die private version der collection :)
let $private-date := $private-collection//atom:updated (: Das Datum der letzten änderung der private collection :) 
let $date := $collection//atom:updated (: das datum der letzten änderung der public collection :)
let $result := if(xs:dateTime($date) >= xs:dateTime($private-date)) (: Vergleiche die beiden Daten :)
            then <result>true</result> (: Ist das Datum der Public collection neuer dann gib true zurück :)
            else <result>false</result> (: Ist das Datum der Private collection neuer dann gibt false zurück :)
       return $result/text()  
 };
 
(: Holt sich sämtliche Collections des angemeldeten Users. :) 
 declare function myProfil:getAllPublicCollections(){  
  let $user-id := $xrx:user-id
  let $collections := collection(concat(conf:param('atom-db-base-uri'),'/metadata.mycollection.public/'))//atom:author[atom:email = $user-id]/root()
  return $collections
 };
 
(: Testet ob zu einer bestimmten Atom:id eine Public-Collection existiert :) 
 declare function myProfil:PublicCollectionHasPrivateVersion($public-id){
 let $result := if(metadata:base-collection('mycollection', 'private')//atom:entry[atom:id=$public-id]) then 'true' else 'false'
 return $result
};

(: Erstellt ein HTML-Div mit den Privatangaben aus der user.xml :) 
declare function myProfil:createPrivateContactBox($user-privateemail,$user-privatephone, $user-privatecountry, $user-privatecity, $user-privatepostalcode, $user-privatestreet, $user-privatehousenumber, $user-facebooklink ){

let $complete-length := string-length(concat($user-privateemail/text(),$user-privatephone/text(), $user-privatecountry/text(), $user-privatecity/text(), $user-privatepostalcode/text(), $user-privatestreet/text(), $user-privatehousenumber/text(), $user-facebooklink/text()))

let $contact-box := if($complete-length>0) then(                
                    <div id="private-info-box" class='contact-box'>                              
                    Private Contacts<br/>
                    Email: {$user-privateemail} <br/>
                    Phone: {$user-privatephone}<br/>  
                    Country: {$user-privatecountry}<br/>
                    City: {$user-privatecity}<br/>
                    Postalcode: {$user-privatepostalcode}<br/>
                    Address: {concat($user-privatestreet," ", $user-privatehousenumber)}<br/>   
                    Facebook-Link <a href="{
                    if(contains($user-facebooklink, 'http')) then( $user-facebooklink)
                    else ( concat("http://", $user-facebooklink)) }">To Facebook Profil</a>  <br/>                          
                    </div>
                    )
                    else()
return $contact-box
};

(:Erstellt ein HTML-Div mit den Institutionsangaben aus der user.xml :) 
declare function myProfil:createInsitutionContactBox($user-institutenname, $user-institutionemail, $user-institutionphone, $user-institutioncountry, $user-institutioncity, $user-privatepostalcode, $user-institutionpostalcode, $user-institutionstreet, $user-privatehousenumber, $user-institutionhousenumber, $user-facebooklink)
{
let $complete-length := string-length(concat($user-institutenname, $user-institutionemail, $user-institutionphone, $user-institutioncountry, $user-institutioncity, $user-privatepostalcode, $user-institutionpostalcode, $user-institutionstreet, $user-privatehousenumber, $user-institutionhousenumber, $user-facebooklink))
let $contact-box :=
                    if($complete-length>0)then(
                    <div id="institute-info-box" class='contact-box'>
                    Institution Contacts<br/>    
                    Name: {$user-institutenname}<br/>
                    Mail: {$user-institutionemail}<br/>  
                    Phone: {$user-institutionphone}<br/>  
                    Country: {$user-institutioncountry}<br/>
                    City: {$user-institutioncity}<br/>
                    Postalcode: {$user-institutionpostalcode}<br/>
                    Address: {concat($user-institutionstreet," ", $user-institutionhousenumber)}<br/>
                    Facebook-Link <a href="{if(contains($user-facebooklink, 'http')) then( $user-facebooklink)
                    else ( concat("http://", $user-facebooklink)) }">To Facebook Profil</a>  <br/>
                      </div>
                      )
                      else()
                      
                      
return $contact-box

};

(: @param $conversations = <xrx:conversations>
                              <xrx:conversation>
                                 <xrx:status></xrx:status>
                                 <xrxconversation-id></xrxconversation-id>
                                 <xrx:path></xrx:path>
                                 <xrx:title></xrx:title>
                                 <xrx:lastfrom></xrx:lastfrom>
                               </xrx:conversation>
                               ...
                            </xrx:conversations>:)
declare function myProfil:createmyConversations($conversations)
{
let $list :=<div id="conversationsdiv">
            {for $conversation in $conversations/xrx:conversation (: für jede conversation in conversations :)
                let $status := $conversation/xrx:status           (: ... nimm den status der conversation :)
                let $id := $conversation/xrx:conversation-id      (: ... Die Ide der Conversation :)
                let $tokenized := tokenize($id,"/")               (: ... Zerhacke die Id jeweils beim / :)
                let $uuid := $tokenized[3]                        (: ... nimm von der zerhacken ID den 3. Part, dies ist die ObjektID. :)
                let $path := $conversation/xrx:path               (: ... Hol dir den Pfad zur datei mit der Conversation :)
                let $title := $conversation/xrx:title             (: ... hol dir den Titel der Conversation :)
                let $from := $conversation/xrx:lastfrom           (: ... Hol dir den Namen des Autors der letzten Message :)
                let $part :=                            
                if($status="ignored") then()                      (: ... ist der Status der Conversation = ignored mach nichts weiter :)    
                else(                                             (: ... ansonsten erstelle ein div :)                      
                <div id="conversation"><span id="conversationTitle">{$title}</span><br/> <!-- Schreibe den Title der Conversation rein, -->
                                {if ($status="new message") then( (: Teste ob der Status der conversation "new message" ist :)
                                       <span> new Message from {$from} </span>) (: ... Wenn ja schreibe wer sie geschrieben hat :)
                                 else(<span> no new Message </span>)}<br/> <!-- Wenn nein teile mit das es keine neue Message in der conversation gibt -->
                                 <a href="{conf:param('request-root')}{$uuid}/conversation">read</a><span> &#160;</span> <!-- ... Erstelle einen Link der zu der Conversation führt. -->
                                 <a href='javascript:ignoreConversation("{$id}", "{$xrx:user-id}")'>ignore</a> <!-- ... Erselle einen Link der angewählt werden kann wenn man die Conversation ignorieren und damit nichtmehr angezeigt bekommen will. -->
                             </div>   )                          
                            return $part
                            
                            }                   
                             </div>
return($list)
};

(: @param $friends =  <xrx:friends>
                         <xrx:friend>
                            <xrx:account></xrx:account>
                            <xrx:status></xrx:status>
                         </xrx:friend>
                         ....
                         </xrx:friends>:) 
declare function myProfil:createFriendlist($friends){
    let $xml := <table>
                {for $friend in $friends/xrx:friend (: Für jeden $friend in $friends :)
                 let $requester-doc :=user:document-by-uuid($friend/xrx:account) (: ... Suche dir anhand der <xrx:account> das dazugehörige User-document:)
                 let $requesterid := $requester-doc//atom:id (: ... Suche die Atom:id des friends:)
                 let $tokenizerequestdid := tokenize($requesterid, '/') (: zerhacke sie an den Stellen mit / :)
                 let $status := $friend//xrx:status (: Nimm dir den Status der Freundschaft :)
                    let $test := 
                    if ($status="request") then (: wenn der Status der Friendship = request ist :)
                     <tr><td>{$requester-doc//xrx:name}</td><td><a href='javascript:createConfirmFriendshipPopup("{$requester-doc//xrx:name}","{$friend//xrx:account}")'>confirm</a></td> <!-- dann Erselle einen Link um die Freundschaft zu bestätgen -->
                     <td><a href='javascript:createIgnoreFriendshipPopup("{$requester-doc//xrx:name}","{$friend//xrx:account}")'>ignore</a></td></tr>                                     (: .. und einen Link um die Anfrage zu ignorieren :)
                     else if($status="friendship") then (<tr><td>{$requester-doc//xrx:name} <a href='javascript:newConversation("{$xrx:user-id}","{$tokenizerequestdid[3]}")'>New conversation</a></td></tr>) (: Ist die freundschaft schon bestätigt erstelle ein Link mit dem man eine neue Conversation starten kann :)
                     else  if($status="ignored") then () (: Ist die Friendship ignoriert erstelle gar nix. :)
                     else() (: Steht irgendwas anderes in status mach gar nix :)
                         return $test}            
                     </table>  
    return $xml
  };
  
 (: @param $user-gamification = <xrx:gamification>
                                            <xrx:active></xrx:active>
                                            [...]
                                            <xrx:rank>
                                                <xrx:Rankname></xrx:Rankname>
                                                [..]
                                            </xrx:rank>
                                            <xrx:achievements>
                                                <xrx:achievement>
                                                    <xrx:achievementname></xrx:achievementname>
                                                    <xrx:achieved></xrx:achieved>
                                                </xrx:achievement>
                                            </xrx:achievements>
                                        </xrx:gamification> :) 
  declare function myProfil:gamificationresults($user-gamification){
  let $gamificationnode := 
  if($user-gamification//xrx:active = 'true') then( (: ... ist gamification aktiviert :)
    let $xml := <div>       
                    <span>User Rank: {$user-gamification//xrx:rank/xrx:Rankname}</span> <!-- Schreibe den Rank auf den der User im Gamification erreicht hat. -->
                            {
                             let $table := 
                                if(empty($user-gamification//xrx:achievement)) then() (: .. Gibt es keine Achievments die der Spieler erreicht hat mach nix :)
                                else( let $result := 
                                        <table id="achievementtable"><tr><th>Achievements</th><th>Achieved</th></tr>{ (: anonsten erstelle eine Tabelle :)
                                            for $achievement in $user-gamification//xrx:achievement (: In der für jedes $achievement in $user-gamification :)
                                                return <tr><td>{$achievement/xrx:achievementname/text()}</td> <!-- eine eigene Zeile angelegt in der der Name des Achievements -->
                                                            <td>{let $datetime := tokenize($achievement/xrx:achieved/text(), 'T') (: ...und das datum gespeichert werden :)
                                                                      return $datetime[1] }</td></tr>}
                                        </table>
                                        return $result)
                                       return $table}
                    </div>
  return $xml
  )
  else(let $xml := <div>Gamification is not Active</div> return $xml) (: Ist die Gamification-funktion nicht aktiviert, dann schreibe nur ein das es deaktiviert ist. :)
  return $gamificationnode
  };
