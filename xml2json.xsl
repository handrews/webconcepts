<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT transforms https://github.com/dret/webconcepts into JSON. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" xmlns:sedola="http://github.com/dret/sedola">
    <xsl:output name="json" method="text" encoding="UTF-8"/>
    <!-- -->
    <xsl:template name="xml2json">
        <xsl:result-document href="{$concepts-dir}/concepts.json" format="json">
            <xsl:text>{&#xa;</xsl:text>
            <xsl:for-each select="$concepts/concepts/concept">
                <xsl:sort select="@id"/>
                <xsl:variable name="concept" select="."/>
                <xsl:value-of select="concat('  &quot;', @id, '&quot;: {&#xa;')"/>
                <xsl:text>    "URI": </xsl:text>
                <xsl:value-of select="concat('&quot;http://webconcepts.info/concepts/', filename-plural, '&quot;,&#xa;')"/>
                <xsl:text>    "name-singular": </xsl:text>
                <xsl:value-of select="concat('&quot;', title-singular, '&quot;,&#xa;')"/>
                <xsl:text>    "name-plural": </xsl:text>
                <xsl:value-of select="concat('&quot;', title-plural, '&quot;,&#xa;')"/>
                <xsl:text>    "concepts": [ &#xa;</xsl:text>
                <xsl:for-each select="distinct-values($allspecs//sedola:*[local-name() eq $concept/@id]/@def)">
                    <xsl:sort select="."/>
                    <xsl:text>    { </xsl:text>
                    <xsl:variable name="concept-name" select="."/>
                    <xsl:value-of select="concat('&quot;', $concept-name, '&quot;: {&#xa;')"/>
                    <xsl:text>      "URI": </xsl:text>
                    <xsl:value-of select="concat('&quot;http://webconcepts.info/concepts/', $concept/filename-singular, '/', $concept-name, '&quot;,&#xa;')"/>
                    <xsl:text>      "details": [</xsl:text>
                    <xsl:for-each select="$allspecs/sedola:service/sedola:*[local-name() eq $concept/@id][@def eq $concept-name]">
                        <xsl:sort select="replace(replace(current()/../@id, $specs/specs/primary[@id eq current()/../@primary]/secondary[@id eq current()/../@secondary]/id-pattern, $specs/specs/primary[@id eq current()/../@primary]/secondary[@id eq current()/../@secondary]/md-pattern), '^(..*)$', $specs/specs/primary[@id eq current()/../@primary]/secondary[@id eq current()/../@secondary]/name-pattern)"/>
                        <xsl:text> {&#xa;</xsl:text>
                        <xsl:text>        "description": </xsl:text>
                        <xsl:value-of select="concat('&quot;', replace(sedola:documentation/text(), '&quot;', '\\&quot;'), '&quot;,&#xa;')"/>
                        <xsl:text>        "documentation": </xsl:text>
                        <xsl:value-of select="concat('&quot;', sedola:documentation/@source, '&quot;,&#xa;')"/>
                        <xsl:text>        "specification": </xsl:text>
                        <xsl:variable name="secondary" select="$specs/specs/primary[@id eq current()/../@primary]/secondary[@id eq current()/../@secondary]"/>
                        <xsl:variable name="id" select="replace(current()/../@id, $secondary/id-pattern, $secondary/md-pattern)"/>
                        <xsl:value-of select="concat('&quot;http://webconcepts.info/', $specs-dir, '/', $secondary/../@id, '/', $secondary/@id, '/', $id, '&quot; }')"/>
                        <xsl:if test="position() ne last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:text> ] } }</xsl:text>
                    <xsl:if test="position() ne last()">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:for-each>
                <xsl:text>    ] }</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
            <xsl:text>}</xsl:text>
        </xsl:result-document>
        <xsl:result-document href="{$specs-dir}/specs.json" format="json">
            <xsl:text>{&#xa;</xsl:text>
            <xsl:for-each-group select="$allspecs/sedola:service" group-by="@primary">
                <xsl:sort select="@primary"/>
                <xsl:value-of select="concat('  &quot;', @primary, '&quot;: {&#xa;')"/>
                <xsl:for-each-group select="current-group()" group-by="@secondary">
                    <xsl:sort select="@secondary"/>
                    <xsl:value-of select="concat('    &quot;', @secondary, '&quot;: {&#xa;')"/>
                    <xsl:for-each select="current-group()">
                        <xsl:sort select="@id"/>
                        <xsl:if test="count($specs/specs/primary[@id eq current()/@primary]) ne 1">
                            <xsl:message terminate="yes" select="concat('Non-matching service/@primary: ', current()/@primary)"/>
                        </xsl:if>
                        <xsl:if test="count($specs/specs/primary[@id eq current()/@primary]/secondary[@id eq current()/@secondary]) ne 1">
                            <xsl:message terminate="yes" select="concat('Non-matching service/@secondary: ', current()/@primary, '/', current()/@secondary)"/>
                        </xsl:if>
                        <xsl:variable name="primary" select="$specs/specs/primary[@id eq current()/@primary]"/>
                        <xsl:variable name="secondary" select="$primary/secondary[@id eq current()/@secondary]"/>
                        <xsl:if test="not(matches(@id, $secondary/id-pattern))">
                            <xsl:message terminate="yes" select="concat('Non-matching service/@id: ', $primary, '/', $secondary, '/', @id)"/>
                        </xsl:if>
                        <xsl:variable name="id" select="replace(@id, $secondary/id-pattern, $secondary/md-pattern)"/>
                        <xsl:value-of select="concat('      &quot;', @id, '&quot;: {&#xa;')"/>
                        <xsl:text>        "title": </xsl:text>
                        <xsl:value-of select="concat('&quot;', replace(sedola:title, '&quot;', '\\&quot;'), '&quot;&#xa;')"/>
                        <xsl:text>      }</xsl:text>
                        <xsl:if test="position() ne last()">
                            <xsl:text>,</xsl:text>
                        </xsl:if>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:for-each>
                    <xsl:text>    }</xsl:text>
                    <xsl:if test="position() ne last()">
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                    <xsl:text>&#xa;</xsl:text>
                </xsl:for-each-group>
                <xsl:text>  }</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>,</xsl:text>
                </xsl:if>
                <xsl:text>&#xa;</xsl:text>
            </xsl:for-each-group>
            <xsl:text>}</xsl:text>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>