<?xml version="1.0" encoding="utf-8"?>
<stylesheet version="1.0" 
  xmlns="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
 	xmlns:vr="http://www.ivoa.net/xml/VOResource/v1.0" 
 	xmlns:vs="http://www.ivoa.net/xml/VODataService/v1.1"
 	xmlns:vm="http://www.ivoa.net/xml/VOMetadata/v0.1"
  >

<!-- extract utypes from VOResource and related XML schema files -->

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
derived from vr:Resource, vr:Capability, and vr:Interface; we should
catch everything in a VOResource extension even if we process file 
by file, unless one extension were to derive from a type defined in
a different extension.

In emulation of the utype generation done by VO-DML, we concatenate
along axes that are simple attribuutes.  When something is actually
a collection, we start a new utype.  The utype fragment is the *name* of
a type or attribute; this means a certain amount of polymorphism.

In addition, for each schema, the prefix chosen for the target name
space becomes the data model name for utype purposes;  when, during
inheritance, we leave a file, the model name changes, too.

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

<!-- types directly derived from another (the key is the name of
the base type); we need this to identify start points for our
tree traversal. -->
<key name="derivations" match="xs:simpleType|xs:complexType"
	use="substring-after(./xs:complexContent/*/@base, ':')"/>


<template name="add-doc">
  <!-- retrieve the "short" doc and add them in parens if present,
  emit an lf either way -->
  <if test="boolean(xs:annotation[1])">
 	  <value-of select="concat(' (', normalize-space(xs:annotation[1]/xs:documentation), ')')"/>
  </if>
 	<text>&#10;</text>
</template>


<template name="concat-dot">
  <!-- concatenate to parts with a dot unless there's another
  non-letter at the end of the first part -->
  <param name="first"/>
  <param name="second"/>
  <choose>
    <when test="substring($first, string-length($first), 1)=':'">
      <value-of select="$first"/><value-of select="$second"/>
    </when>
    <otherwise>
      <value-of select="$first"/>.<value-of select="$second"/>
    </otherwise>
  </choose>
</template>


<template name="emit-utype-for-current">
  <!-- prints a utype for the current element -->
  <param name="parent-path"/>

  <call-template name="concat-dot">
     <with-param name="first" select="$parent-path"/>
     <with-param name="second" select="@name"/>
  </call-template>
   <call-template name="add-doc"/>
</template>

<template name="format-for-attribute">
  <!-- emits utypes for an within a type if the element is 0..1:1 -->

  <param name="parent-path"/>

  <!-- capability and interface are roots of their own -->
	<if test="@name!='capability' and @name!='interface'">
    
    <call-template name="emit-utype-for-current">
      <with-param name="parent-path" select="$parent-path"/>
    </call-template>

	  <variable name="child-type"
		  select="substring-after(@type, ':')"/>

	  <if test="key('definitions', $child-type)">
      <variable name="child-path">
	      <call-template name="concat-dot">
          <with-param name="first" select="$parent-path"/>
          <with-param name="second" select="@name"/>
	      </call-template>
	    </variable>
		  <for-each select="key('definitions', $child-type)">
			  <call-template name="walk">
  			  <with-param name="parent-path" select="$child-path"/>
  		  </call-template>
  	  </for-each>
    </if>
  </if>
</template>

<template name="walk">
	<!-- the central (recursive) template building up utypes by
	collecting subelements; the current node here is a type definition -->

  <param name="parent-path"/>

  <for-each select="descendant::xs:attribute">
 	  <call-template name="concat-dot">
       <with-param name="first" select="$parent-path"/>
       <with-param name="second" select="@name"/>
 	  </call-template>
  	<call-template name="add-doc"/>
  </for-each>

  <for-each select="descendant::xs:element">
    <choose>

      <when test="@maxOccurs='unbounded'">
        <!-- emit a utype of the collection, then start a new utype hierarchy
        -->
        <call-template name="emit-utype-for-current">
          <with-param name="parent-path" select="$parent-path"/>
        </call-template>

        <variable name="new-root"
          select="concat(substring-before(@type, ':'), ':')"/>

        <for-each 
            select="key('definitions', substring-after(@type, ':'))">
          <call-template name="format-for-type">
            <with-param name="parent-path" select="$new-root"/>
          </call-template>
        </for-each>
      </when>

      <otherwise>
        <call-template name="format-for-attribute">
          <with-param name="parent-path" select="$parent-path"/>
        </call-template>
      </otherwise>

    </choose>
  </for-each>
</template>


<template name="format-for-type">
  <!-- generates utypes for the current type and the classes it is derived 
  from -->
  <param name="parent-path"/>

  <variable name="type-path">
    <call-template name="concat-dot">
      <with-param name="first" select="$parent-path"/>
      <with-param name="second" select="@name"/>
    </call-template>
  </variable>

  <value-of select="$type-path"/>
  <call-template name="add-doc"/>

  <call-template name="walk">
    <with-param name="parent-path" select="$type-path"/>
  </call-template>

  <call-template name="walk-in-hierarchy">
    <with-param name="base-type" select="@name"/>
    <with-param name="parent-path" select="$parent-path"/>
  </call-template>
</template>


<template name="walk-in-hierarchy">
  <!-- generates utypes for stuff derived from base-type -->
  <param name="base-type"/>
  <param name="parent-path"/>

  <for-each select="key('definitions', 
      substring-after(./xs:complexContent|xs:simpleContent/*/@base, ':'))">
    <call-template name="format-for-type">
      <with-param name="parent-path" select="$parent-path"/>
    </call-template>
  </for-each>

  <for-each select="key('derivations', @name)">
    <call-template name="format-for-type">
      <with-param name="parent-path" select="$parent-path"/>
    </call-template>
  </for-each>
</template>


<template match="xs:complexType">
  <!-- initiates a walk through the tree of child constructs if the
  current element is a resource, capability, or interface, or directly
  derived from one of those -->

  <variable name="uqbase" 
    select="substring-after(./xs:complexContent/*/@base, ':')"/>
  <if test="@name='Resource' or @name='Interface' or @name='Capability'
    or @name='DataType'
    or $uqbase='Resource' or $uqbase='Interface' or $uqbase='Capability'">

    <call-template name="format-for-type">
      <with-param name="parent-path" 
        select="concat(//xs:appinfo/vm:targetPrefix, ':')"/>
    </call-template>
  </if>
</template>


<template match="/">
  <apply-templates/>
</template>

<template match="text()"/> 

</stylesheet>
<!-- vi:et:sw=2:sta
-->
