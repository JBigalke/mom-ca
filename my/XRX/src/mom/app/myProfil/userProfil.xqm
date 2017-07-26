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

module namespace userProfil = "http://www.monasterium.net/NS/userProfil";

import module namespace xrx="http://www.monasterium.net/NS/xrx" at "xmldb:exist:///db/XRX.live/mom/app/xrx/xrx.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf" at "xmldb:exist:///db/XRX.live/mom/app/xrx/conf.xqm";
import module namespace mycollection="http://www.monasterium.net/NS/mycollection" at "../collection/mycollection.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata" at "../metadata/metadata.xqm";
import module namespace myProfil="http://www.monasterium.net/NS/myProfil" at "../myProfil/myProfil.xqm";

    
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace xhtml="http://www.w3.org/1999/xhtml";
declare namespace bfc="http://betterform.sourceforge.net/xforms/controls";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace cei="http://www.monasterium.net/NS/cei";

(: @param: $user-profil = user.xml des Profilbesitzers 
   @param: $current-user-uuid = uuid des derzeit angemeldeten users :)
declare function userProfil:getFriendshipstatus($user-profil,$current-user-uuid){
let $status :=
    if ($user-profil//xrx:friends/xrx:friend[xrx:account=$current-user-uuid][xrx:status="friendship"]) then <result>friendship</result>
    else if($user-profil//xrx:friends/xrx:friend[xrx:account=$current-user-uuid][xrx:status="request"]) then <result>requested</result>
    else if($user-profil//xrx:friends/xrx:friend[xrx:account=$current-user-uuid][xrx:status="ignored"]) then <result>requested</result>
    else <result>false</result>        
    return $status
};

(: @param: $author-email = Emailadresse des besitzers des profils :)
declare function userProfil:getPublicCollections-atomids($author-email)
{
(: Hohl dir alle Public collections des Besitzers des Profils :)
let $public-mycollections := collection(concat($atom:db-base-uri, metadata:feed('mycollection','public')))//atom:email[contains(.,$author-email)]
let $public-collections := collection(concat($atom:db-base-uri, metadata:feed('collection','public')))//atom:email[contains(.,$author-email)]

(: erstelle eine Xml in der die IDs der collections und der Title gespeichert werden :)
let $public-mycollection-ids := 
for $public-mycollection in $public-mycollections
 return <xrx:collection>{root($public-mycollection)//atom:id}<xrx:title>{root($public-mycollection)//cei:title/text()}</xrx:title></xrx:collection>
 
let $public-collection-ids :=
 for $public-collection in $public-collections
 return <xrx:collection>{root($public-collection)//atom:id}<xrx:title>{root($public-collection)//cei:title/text()}</xrx:title></xrx:collection>

return ($public-mycollection-ids, $public-collection-ids)
};

(: @param: $collection-ids =  xmls von userProfil:getPublicCollections-atomids :)
declare function userProfil:buildPublicCollectionList($collection-ids){
  let $list :=
  (: Wenn $collection-ids leer ist tu nichts :)
   if(empty($collection-ids)) then()
  (: Ansonsten erstelle eine liste :)
   else(
    <li id='publiccollection-list'>
     {
     (: ... Fpr jede collection-id  :)
     for $collection-id in $collection-ids
     (: ...  hohl dir dazu die atom:id :)
      let $atomid := $collection-id/atom:id/text() 
     (: ... den xrx:title :)
      let $title := $collection-id/xrx:title/text()
     (: Zerhacke die atom:id an den / :)
      let $tokenized := tokenize($atomid, '/')
      (: Erstelle einen eintrag  mit einem Link zu der Collection :)
      let $part := 
        <ul><a href="{concat(conf:param('request-root'),$tokenized[3],'/','collection')}">{$title}</a></ul>
      return $part}
      </li>
      )
   return $list
};