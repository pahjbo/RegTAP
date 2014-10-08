<?xml version="1.0"?>
<stylesheet version="1.0"
	xmlns:v="http://www.ivoa.net/xml/VOTable/v1.2"
	xmlns="http://www.w3.org/1999/XSL/Transform">

<output method="text"/>
<strip-space elements="*"/>

<template match="text()"/>

<template match="v:TABLE">
\begin{inlinetable}
\small
\begin{tabular}{p{0.3\textwidth}p{0.16\textwidth}p{0.68\textwidth}}\\
\hline
\noalign{\vspace{3pt}}
\multicolumn{3}{l}{\textit{Column names, utypes, ADQL types, and descriptions for the \rtent{rr.<value-of select="@name"/>} table}}\\
\noalign{\vspace{2pt}}
\hline
\noalign{\vspace{2pt}}
<apply-templates/>
\noalign{\vspace{2pt}}
\hline
\end{tabular}
\end{inlinetable}

</template>


<template match="v:TR">
<value-of select="v:TD[1]"/>\hfil\break
\scriptsize\ttfamily <value-of select="v:TD[2]"/>&amp;
\footnotesize <value-of select="v:TD[3]"/>(<choose>
	<when test="v:TD[4]='-1'">*</when>
	<otherwise><value-of select="v:TD[4]"/></otherwise></choose>)&amp;
<value-of select="v:TD[5]"/>\\
</template>

</stylesheet>
