<?xml version="1.0"?>
<stylesheet version="1.0"
	xmlns:v="http://www.ivoa.net/xml/VOTable/v1.2"
	xmlns="http://www.w3.org/1999/XSL/Transform">

<output method="text"/>
<strip-space elements="*"/>

<template match="text()"/>


<template match="v:TABLE[@name='tables']/v:DATA/v:TABLEDATA">
\begin{table}[t]
\small
\hbox to\hsize{\hss
\begin{tabular}{p{0.35\textwidth}p{0.64\textwidth}}\\
\hline
\noalign{\vspace{2pt}}
\textbf{Name and UType}&amp;\textbf{Description}\\
\noalign{\vspace{2pt}}
\hline
\noalign{\vspace{2pt}}
<apply-templates/>
\noalign{\vspace{2pt}}
\hline
\end{tabular}\hss}
\caption{The tables making up the TAP data model \texttt{Registry 1.0}}
\label{table:dm}
\end{table}
</template>


<template match="v:TR">
<value-of select="v:TD[1]"/>\hfil\break
\scriptsize\ttfamily <value-of select="v:TD[2]"/>&amp;
<value-of select="v:TD[3]"/>\\
</template>

</stylesheet>
