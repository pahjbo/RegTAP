<?xml version="1.0" encoding="utf-8"?>
<stylesheet version="1.0" 
  xmlns="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
 	xmlns:vr="http://www.ivoa.net/xml/VOResource/v1.0" 
 	xmlns:vs="http://www.ivoa.net/xml/VODataService/v1.1"
  >

<!-- extract RegTAP xpath from VOResource and related XML schema files -->

<!--
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    For the complete text of the GPL, see http://www.gnu.org/licenses/.
-->

<!-- The basic strategy here is: start from all discernible types
derived from vr:Resource, vr:Capability, and vr:Interface; we need to
handle capability and interface separately since they may not be
explicitely reachable from a resource due to the way capability and
interface types are declared in VOResource (i.e., through xsi:type).

Each root is the start element for a recursion yielding the utypes.
During this recursion, attributes yield utypes by concatenating the
parent name with the attribute name, and elements yield utypes by
concatenating the element name with the parent name.  Elements take part
in the recursion, where their utype becomes the new parent name.

Note that the xpaths generated here are the ones used in the 
res_details table.  For the xpaths used in lieu of utypes in
TAP_SCHEMA and VOSI tables, you'll want to make them relative.

Hack alert: We need to traverse the type tree; however, due to 
(practical) limitations of XSLT1, we don't do that across files.  So,
if a type were to inherit from a class derived from VOResource or Capability
in another document, this stylesheet would not notice.  Also, we kill all
namespace prefixes in attributes.  Proper handling of that probably is
close to impossible with XSLT1.  -->

<output method="text"/>
<strip-space elements="*"/>


<!-- An index used to retrieve the type definitions for the child
elements in walk; note that this only spans one file,
which is the primary limitation of this program -->
<key name="definitions" match="xs:simpleType|xs:complexType"
	use="@name"/>

<!-- A map from types to the names of their base classes; this is
a bit haphazard since we don't want to use XSLT extensions that
actually understand XML schema.  A recursion within the type
hierarchy takes place in walk-for-type -->
<key name="of-type" match="xs:complexType"
  use="substring-after(./xs:complexContent/*/@base, ':')"/>


<template name="add-doc">
  <!-- retrieve the "short" doc and add them in parens if present,
  emit an lf either way -->
  <if test="boolean(xs:annotation[1])">
 	  <value-of select="concat(' (', normalize-space(xs:annotation[1]/xs:documentation), ')')"/>
  </if>
 	<text>&#10;</text>
</template>


<template name="walk">
	<!-- the central (recursive) template building up utypes by
	collecting subelements; the current node here is a type definition -->

  <param name="parent-path"/>

  <for-each select="descendant::xs:attribute">
  	<value-of select="concat($parent-path, '/@', @name)"/>
  	<call-template name="add-doc"/>
  </for-each>

  <for-each select="descendant::xs:element">
    <!-- capability and interface are roots of their own -->
  	<if test="@name!='capability' and @name!='interface'">
      <value-of select="concat($parent-path, '/', @name)"/>
      <call-template name="add-doc"/>

  	  <variable name="child-type"
  		  select="substring-after(@type, ':')"/>
  	  <if test="key('definitions', $child-type)">
 	       <variable name="child-path"
 	         select="concat($parent-path, '/', @name)"/>
  		  <for-each select="key('definitions', $child-type)">
  			  <call-template name="walk">
    			  <with-param name="parent-path" select="$child-path"/>
    		  </call-template>
    	  </for-each>
      </if>
    </if>
  </for-each>
 
  <!-- collect attributes and elements for our node from the types
  we are derived from, too -->
  <for-each select="descendant::xs:extension|descendant::xs:restriction">
    <for-each select="key('definitions', substring-after(@base, ':'))">
      <call-template name="walk">
        <with-param name="parent-path" select="$parent-path"/>
      </call-template>
    </for-each>
  </for-each>
</template>


<template name="walk-for-type">
  <!-- iterates over the types and elements derived from base-type -->
  <param name="base-type"/>
  <param name="parent-path"/>
  <for-each select="key('of-type', $base-type)">

    <call-template name="walk">
      <with-param name="parent-path" select="$parent-path"/>
    </call-template>

    <call-template name="walk-for-type">
      <with-param name="base-type" select="@name"/>
      <with-param name="parent-path" select="$parent-path"/>
    </call-template>

  </for-each>
</template>


<!-- templates cover the immediate types; the derived types are handled
in explicit call-templates in the the template for root below. -->
<template match="//xs:complexType[@name='Resource']">
	<call-template name="walk">
		<with-param name="parent-path" select="'Resource'"/>
	</call-template>
</template>

<template match="//xs:complexType[@name='Capability']">
	<call-template name="walk">
		<with-param name="parent-path" select="'Capability'"/>
	</call-template>
</template>

<template match="//xs:complexType[@name='Interface']">
	<call-template name="walk">
		<with-param name="parent-path" select="'Interface'"/>
	</call-template>
</template>



<template match="/">
  <apply-templates/>

  <call-template name="walk-for-type">
		<with-param name="base-type" select="'Resource'"/>
		<with-param name="parent-path" select="''"/>
	</call-template>

  <call-template name="walk-for-type">
		<with-param name="base-type" select="'Capability'"/>
		<with-param name="parent-path" select="'/capability'"/>
	</call-template>

  <call-template name="walk-for-type">
		<with-param name="base-type" select="'Interface'"/>
		<with-param name="parent-path" select="'/capability/interface'"/>
	</call-template>

</template>

<template match="text()"/> 

</stylesheet>
<!-- vi:et:sw=2:sta
-->
