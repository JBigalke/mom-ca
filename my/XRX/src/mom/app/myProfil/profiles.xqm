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

module namespace profiles = "http://www.monasterium.net/NS/profiles";


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

(:@PARAM: $profiles = xrx-user/*.user.xml:)
declare function profiles:createProfileList($profiles){
(: Hohl dir das user.doc des angemeldeten Users :)
let $userdoc := user:document($xrx:user-id)

(: Sortiere alle Profile nach Namen nimm aber nur die mit einer atom:id. :)
let $sortedProfiles := for $profil in $profiles[atom:id] order by $profil//xrx:name return $profil
(: erstelle eine Tabelle :) 
let $tableNode := 
 <table>
 {
    (: Für jedes Profile :) 
    for $profil in $sortedProfiles
     (: Zerhacke die AtomId des Profiles an den / :)
     let $tokenizedAtomId := tokenize($profil//atom:id, '/')
     let $row :=
        (: Wenn die Atom-id die gleiche ist wie die aus dem user.xml, des angemeldeten users dann mach nix :)
        if( $profil//atom:id = $userdoc//atom:id) then ()
        (: ... ansonsten erstelle eine Tabelleneintrag mit dem namen des Profils und dem link zu diesem :)   
        else( <tr><td><a href="{conf:param('request-root')}{$tokenizedAtomId[last()]}/UserProfil">{concat($profil/xrx:name," " ,$profil/xrx:firstname)}</a></td></tr>)
     return $row
 }
 </table>
 return $tableNode
};
