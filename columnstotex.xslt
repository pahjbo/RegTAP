<?xml version="1.0"?>
<stylesheet version="1.0"
	xmlns:v="http://www.ivoa.net/xml/VOTable/v1.3"
	xmlns="http://www.w3.org/1999/XSL/Transform">

<output method="text"/>
<strip-space elements="*"/>

<template match="text()"/>

<template match="v:TABLE">
\begin{inlinetable}
\small
\begin{tabular}{p{0.28\textwidth}p{0.2\textwidth}p{0.66\textwidth}}
\sptablerule
\multicolumn{3}{l}{\textit{Column names, utypes, ADQL types, and descriptions for the \rtent{rr.<value-of select="@name"/>} table}}\\
\sptablerule
<apply-templates/>
\sptablerule
\end{tabular}
\end{inlinetable}

</template>

<template name="string-replace">
	<!-- exslt compatible... -->
  <param name="string" />
  <param name="search" />
  <param name="replace" />
  <choose>
    <when test="contains($string, $search)">
      <value-of select="substring-before($string,$search)" />
      <value-of select="$replace" />
      <call-template name="string-replace">
        <with-param name="string" 
          select="substring-after($string,$search)" />
        <with-param name="search" select="$search" />
        <with-param name="replace" select="$replace" />
      </call-template>
    </when>
    <otherwise>
      <value-of select="$string" />
    </otherwise>
  </choose>
</template>

<template match="v:TR">
<value-of select="v:TD[1]"/>\hfil\break
\makebox[0pt][l]{\scriptsize\ttfamily <value-of select="v:TD[2]"/>}&amp;
\footnotesize <value-of select="v:TD[3]"/>(<choose>
	<when test="v:TD[4]='-1'">*</when>
	<otherwise><value-of select="v:TD[4]"/></otherwise></choose>)&amp;
<call-template name="string-replace">
	<with-param name="string" select="v:TD[5]"/>
	<with-param name="search" select="'#'"/>
	<with-param name="replace" select="'\\#'"/>
</call-template>\\
</template>

</stylesheet>
