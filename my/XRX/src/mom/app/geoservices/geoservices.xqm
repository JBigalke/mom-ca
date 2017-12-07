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
module namespace geoservices="http://www.monasterium.net/NS/geoservices";


import module namespace jsonx="http://www.monasterium.net/NS/jsonx" at "xmldb:exist:///db/XRX.live/mom/app/xrx/jsonx.xqm";
import module namespace metadata="http://www.monasterium.net/NS/metadata" at "xmldb:exist:///db/XRX.live/mom/app/metadata/metadata.xqm";
import module namespace cei="http://www.monasterium.net/NS/cei" at "xmldb:exist:///db/XRX.live/mom/app/metadata/cei.xqm";
import module namespace conf="http://www.monasterium.net/NS/conf" at "xmldb:exist:///db/XRX.src/core/app/xrx/conf.xqm";


declare namespace geo = "http://www.monasterium.net/NS/geo";
declare namespace eag= "http://www.archivgut-online.de/eag";
import module namespace atom="http://www.w3.org/2005/Atom" at "xmldb:exist:///db/XRX.live/mom/app/data/atom.xqm";


declare function geoservices:merge_locations_charters($geoxml, $charters){
         
         
         let $xml := 
                 <result>
                    <locations>
                        {
                        for $location in $geoxml//geo:location
                        let $geoid := $location//geo:geoname_id/text()
                        return <location>
                                <geoname>{$location/geo:name/text()}</geoname>
                                <geonames_id>{$geoid}</geonames_id>
                                <lat>{$location/geo:lat/text()}</lat>
                                <lng>{$location/geo:lng/text()}</lng>
                                <who>{$location/geo:who/text()}</who>
                                <charters>
                                {
                                for $entry in $charters//cei:issued/cei:placeName[@key/string()=$geoid]
                                let $charter := root($entry)
                                let $tokenizedatomid := tokenize($charter//atom:id/text(),'/')
                                let $tokenslength := count($tokenizedatomid)
                                 return 
                                     <charter>
                                     <id>{$charter//atom:id/text()}</id>
                                     <url>{
                                        switch($tokenslength)
                                        case 5 return concat("http://monasterium.net/mom/",$tokenizedatomid[3],"/",$tokenizedatomid[4],'/',$tokenizedatomid[5],'/charter')
                                        case 4 return concat("http://monasterium.net/mom/",$tokenizedatomid[3],"/",$tokenizedatomid[4],'/charter')
                                        default return "Error"
                                           }</url>
                                     <issued>{                                     
                                     if($charter//cei:issued/cei:date) then $charter//cei:issued/cei:date/text()
                                     else($charter//cei:issued/cei:dateRange/text())
                                     
                                     }</issued>
                                     </charter>
                                 }
                                </charters>
                            </location>
                            }
                    </locations>
                  </result>
                  
                  return $xml

};


declare function geoservices:merge_locations_archives($geoxml, $archivegeoxml){


let $mergedxml := <result>
                    <locations>
                        {
                        for $location in $geoxml//geo:location
                        let $geoid := $location//geo:geoname_id/text()
                        return <location>
                                <geoname>{$location/geo:name/text()}</geoname>
                                <geonames_id>{$geoid}</geonames_id>
                                <lat>{$location/geo:lat/text()}</lat>
                                <lng>{$location/geo:lng/text()}</lng>
                                <who>{$location/geo:who/text()}</who>
                                <archives>
                                {
                                for $archive in $archivegeoxml//archive[geonames_id/text()=$geoid]
                                 let $tokenizedatomid := tokenize($archive/atom:id/text(),'/')                                        
                                        let $archivedoc := doc(concat(metadata:base-collection-path('archive','public'),$tokenizedatomid[3],'/',$tokenizedatomid[3],'.eag.xml'))
                                        return 
                                     <archive>                           
                                        
                                        <id>{$archive/atom:id/text()}</id>
                                        <name>{$archivedoc//eag:autform/text()}</name>
                                        <url>{concat("http://www.monasterium.net/mom/",$tokenizedatomid[3],"/archive")}</url>
                                        
                                        
                                     </archive>
                                 }
                                </archives>
                            </location>
                            }
                    </locations>
                  </result>
                  
  return $mergedxml 

};


declare function geoservices:create_charter_json($xml){

let $json :=  jsonx:object(
               jsonx:pair(
                jsonx:string("geolocations"),
                jsonx:array(
                 for $location in $xml//location[charters/charter]
                  return   jsonx:object(( 
                            jsonx:pair(
                             jsonx:string("geoname"),
                             jsonx:string($location/geoname)
                            ),
                            jsonx:pair(
                            jsonx:string("lat"),
                            jsonx:string($location/lat)
                           ),
                           jsonx:pair(
                            jsonx:string("lng"),
                            jsonx:string($location/lng)
                           ),
                           jsonx:pair(
                            jsonx:string("who"),
                            jsonx:string($location/who)
                           ),
                           jsonx:pair(
                           jsonx:string("charters"),
                        jsonx:array(
                          for $charter in $location//charters/charter
                         return jsonx:object((
                          jsonx:pair(
                           jsonx:string("url"),
                           jsonx:string($charter/url)
                          ),
                          jsonx:pair(
                           jsonx:string("id"),
                           jsonx:string($charter/id)
                          ),
                         jsonx:pair(
                          jsonx:string("issued"),
                          jsonx:string($charter/issued)
                          )
                        ))
                      )
                    )     
                ))
               )
              )
             )
             
             return $json
};

declare function geoservices:create_archive_json($xml){

let $json := jsonx:object(
               jsonx:pair(
                jsonx:string("geolocations"),
                jsonx:array(
                 for $location in $xml//location[archives/archive]
                  return   jsonx:object(( 
                            jsonx:pair(
                             jsonx:string("geoname"),
                             jsonx:string($location/geoname)
                            ),
                            jsonx:pair(
                            jsonx:string("lat"),
                            jsonx:string($location/lat)
                           ),
                           jsonx:pair(
                            jsonx:string("lng"),
                            jsonx:string($location/lng)
                           ),
                           jsonx:pair(
                            jsonx:string("who"),
                            jsonx:string($location/who)
                           ),
                           jsonx:pair(
                           jsonx:string("archives"),
                        jsonx:array(
                         for $archive in $location//archives/archive
                         return jsonx:object((
                          jsonx:pair(
                           jsonx:string("id"),
                           jsonx:string($archive/id)
                          ),
                          jsonx:pair(
                           jsonx:string("displayText"),
                           jsonx:string($archive/name)
                          ),
                         jsonx:pair(
                          jsonx:string("url"),
                          jsonx:string($archive/url)
                          )
                        ))
                      )
                    )     
                ))
               )
              )
             )
             return $json
};


