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


module namespace resolver="http://www.monasterium.net/NS/resolver";

declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xrx="http://www.monasterium.net/NS/xrx";

(: Resolves to the requested resource or an error page if the current request is requesting a non-existing mom-ca
 : resource like a invalid charter url :)
declare function resolver:resolve($live-project-db-base-collection) as element()* {
    let $first-match := (
            for $uri-pattern in $live-project-db-base-collection//xrx:resolver/xrx:map/xrx:uripattern
                let $priority := ($uri-pattern/parent::xrx:map/@priority/string(), '999')[1]
                order by $priority ascending
                return
                    if(matches(request:get-uri(), $uri-pattern/text())) then
                        $uri-pattern/parent::xrx:map
                    else
                        ()
        )[1]
    return
        if (resolver:is-resource-existing()) then
            $first-match
        else
            <xrx:map>
                <xrx:uripattern>/error$</xrx:uripattern>
                <xrx:mode>mainwidget</xrx:mode>
                <xrx:atomid>tag:www.monasterium.net,2011:/mom/widget/error</xrx:atomid>
            </xrx:map>
};

(:  Returns true if the currently requested resource is either any non-mom-ca resource like a stylesheet or
 :  an existing mom-ca resource. Returns false for non-existing mom-ca resources :)
declare function resolver:is-resource-existing() as xs:boolean {
    let $uri-tokens := tokenize(request:get-uri(), "/")
    let $resource-type := $uri-tokens[last()]
    let $resource-db-path := resolver:create-resource-db-path($uri-tokens, $resource-type)



    return
    (: Test if there are special-characters the to
     : If true test if ressource exists over Atom:id
     : If false try to find ressource file in database
    :)
        if(matches(xmldb:decode(request:get-uri()),'[|<>()\]\[]')) then
           let $is-existing := resolver:check-existing-over-id($uri-tokens, $resource-type)
           return
            if(not($is-existing) and $resource-type = "collection") then
                resolver:is-mycollection-existing($uri-tokens)
            else 
             $is-existing 
        
        else
            if(not(exists($resource-db-path))) then
                true()
            else
                let $is-existing := exists(doc($resource-db-path))
                return
                    if(not($is-existing) and $resource-type = "collection") then
                        resolver:is-mycollection-existing($uri-tokens)
                    else
                        $is-existing
    };

(: Tests whether or not a mycollection as indicated by a request is existing :)
declare function resolver:is-mycollection-existing($uri-tokens as xs:string*) as xs:boolean {
    let $mycollection-atomid-string := "tag:www.monasterium.net,2011:/mycollection/" || $uri-tokens[last()-1]
    let $mycollection-atomid := collection("/db/mom-data/xrx.user")//atom:id[. = $mycollection-atomid-string]
    return
        exists($mycollection-atomid)
        
};

(: Creates mom-ca resource paths from the current request. Returns the database path to the resource or () if the current
 : request is for a non-resource like a stylesheet or the home page. :)
declare function resolver:create-resource-db-path($uri-tokens as xs:string*, $resource-type as xs:string) as xs:string? {
    switch($resource-type)
        case "charter" return
            if(count($uri-tokens) = 6) then
                (: fond charter :)
                "/db/mom-data/metadata.charter.public/" || $uri-tokens[last()-3] || "/" ||  $uri-tokens[last()-2] || "/" || $uri-tokens[last()-1] || ".cei.xml"
            else
                (: collection charter :)
                "/db/mom-data/metadata.charter.public/" || $uri-tokens[last()-2] || "/" || $uri-tokens[last()-1] || ".cei.xml"
        case "collection" return
            "/db/mom-data/metadata.collection.public/" || $uri-tokens[last()-1] || "/" || $uri-tokens[last()-1] || ".cei.xml"
        case "fond" return
            "/db/mom-data/metadata.fond.public/" || $uri-tokens[last()-2] || "/" || $uri-tokens[last()-1] || "/" || $uri-tokens[last()-1] || ".ead.xml"
        case "archive" return
            "/db/mom-data/metadata.archive.public/" || $uri-tokens[last()-1] || "/" || $uri-tokens[last()-1] || ".eag.xml"
        default return
            ()
};

(: Tries to find a document over the atom:id element returns true when it exists :)
declare function resolver:check-existing-over-id($uri-tokens as xs:string*, $resource-type as xs:string) as xs:boolean? {
    switch($resource-type)
        case "charter" return 
            if(count($uri-tokens)=6) then
              exists(collection("/db/mom-data/metadata.charter.public/" || $uri-tokens[last()-3] || "/" ||  $uri-tokens[last()-2])//atom:id[text()="tag:www.monasterium.net,2011:/charter/" || $uri-tokens[last()-3] || "/" ||$uri-tokens[last()-2] || "/" || $uri-tokens[last()-1]])
             else 
              exists(collection("/db/mom-data/metadata.charter.public/" || $uri-tokens[last()-2])//atom:id[text()="tag:www.monasterium.net,2011:/charter/" ||$uri-tokens[last()-2] || "/" || $uri-tokens[last()-1]])
        case "fond" return
              exists(collection("/db/mom-data/metadata.fond.public/" || $uri-tokens[last()-2] || "/" || $uri-tokens[last()-1])//atom:id[text()="tag:www.monasterium.net,2011:/fond/" || $uri-tokens[last()-2] || "/" || $uri-tokens[last()-1]])
        case "archive" return
              exists(collection("/db/mom-data/metadata.archive.public/" || $uri-tokens[last()-1] || "/")//atom:id[text()="tag:www.monasterium.net,2011:/archive/" || "/" || $uri-tokens[last()-1]])
       default return()
};