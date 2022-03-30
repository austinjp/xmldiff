# xmldiff

## What?

A *very basic* diff tool for XML. Kinda, sorta. Built for bash on Linux.

## Why?

Apparently there aren't many. And it scratched an itch for me.

## Install

Requires Python 3, [gron](https://github.com/tomnomnom/gron) and [jq](https://stedolan.github.io/jq/), plus the standard tools `grep`, `diff` and `sed`. Optionally, if you have either of `xmllint` (which you can probably install with something like `sudo apt-get install libxml2-utils`) and/or [batcat](https://github.com/sharkdp/bat) installed, `xmldiff` will use them to pretty-print the output.

Download <https://raw.githubusercontent.com/austinjp/xmldiff/main/xmldiff.bash> and put it in your `$PATH`. Add a symlink for convenience, like this:

```sh
cd $(dirname $(which xmldiff.bash)) && ln -s xmldiff.bash xmldiff
```

## Usage

```
xmldiff /path/to/a.xml /path/to/b.xml
```

### Output

The output is *not a diff*. Sorry about that. Instead, it's a chunk of XML which represents the difference between files `a.xml` and `b.xml`. For example:

```xml
<?xml version="1.0" encoding="utf-8"?><!-- File a.xml -->
<TEI>
  <teiHeader>
    <fileDesc>
      <sourceDesc>
        <biblStruct>
          <analytic>
            <author>
              <affiliation key="aff0">
                <address>
                  <addrLine>999 Letsbe Avenue</addrLine>
                  <country key="GB">United Kingdom</country>
                  <postCode>W1A 1AA</postCode>
                  <settlement>London</settlement>
                </address>
                <orgName type="department">Department of Whatever. School of Stuff. Some University. Some City.</orgName>
              </affiliation>
              <affiliation key="aff1">
                <orgName type="institution">Institute for Things</orgName>
              </affiliation>
              <persName>
                <forename>Jeff</forename>
                <surname>Bezos</surname>
              </persName>
            </author>
            <author role="corresp">
              <affiliation key="aff0">
                <address>
                  <addrLine>999 Letsbe Avenue</addrLine>
                  <country key="GB">United Kingdom</country>
                  <postCode>W1A 1AA</postCode>
                  <settlement>London</settlement>
                </address>
                <orgName type="department">Department of Whatever. School of Stuff. Some University. Some City.</orgName>
              </affiliation>
              <email>whomsoever@example.com</email>
              <persName>
                <forename>Betty</forename>
                <surname>Crocker</surname>
              </persName>
            </author>
          </analytic>
        </biblStruct>
      </sourceDesc>
    </fileDesc>
  </teiHeader>
</TEI>
```

```xml
<?xml version="1.0" encoding="utf-8"?><!-- File b.xml -->
<TEI>
  <teiHeader>
    <fileDesc>
      <sourceDesc>
        <biblStruct>
          <analytic>
            <author>
              <affiliation key="aff0">
                <address>
                  <addrLine>999 Letsbe Avenue</addrLine>
                  <country key="GB">United Kingdom</country>
                  <settlement>London</settlement>
                  <postCode>W1A 1AA</postCode>
                </address>
                <orgName type="department">Depatment of Whatever. School of Stuff. Some University. Some City.</orgName>
              </affiliation>
              <persName>
                <forename>Jeff</forename>
                <surname>Bezos</surname>
              </persName>
              <affiliation key="aff2">
                <orgName type="institution">Institute for Things</orgName>
              </affiliation>
            </author>
            <author role="corresp">
              <affiliation key="aff0">
                <address>
                  <addrLine>999 Letsbe Avenue</addrLine>
                  <country key="GB">United Kingdom</country>
                  <postCode>W1A 1AA</postCode>
                  <settlement>London</settlement>
                </address>
                <orgName type="department">Department of Whatever. School of Stuff. Some University. Some City.</orgName>
              </affiliation>
              <email>whomsoever@example.com</email>
            </author>
            <persName>
              <forename>Betty</forename>
              <surname>Crocker</surname>
            </persName>
          </analytic>
        </biblStruct>
      </sourceDesc>
    </fileDesc>
  </teiHeader>
</TEI>
```

Note the differences:

  - An organisation name has a typo.
  - A property value has changed.

Also, some elements have swapped places:

  - The children within the first `<address>` are in a different order.
  - Jeff Bezo's `<persName>` has hopped above `<affiliation>`.
  - Betty Crocker's `<persName>` has moved out from under `<author>` to become a child of `<analytic>`.

Running `xmldiff a.xml b.xml` will produce the following output:

```xml
<?xml version="1.0" encoding="utf-8"?>
<TEI>
  <teiHeader>
    <fileDesc>
      <sourceDesc>
        <biblStruct>
          <analytic>
            <author>
              <affiliation>
                <orgName>Depatment of Whatever. School of Stuff. Some University. Some City.</orgName>
              </affiliation>
              <affiliation key="aff2"/>
            </author>
            <persName>
              <forename>Betty</forename>
              <surname>Crocker</surname>
            </persName>
          </analytic>
        </biblStruct>
      </sourceDesc>
    </fileDesc>
  </teiHeader>
</TEI>
```

Some of the elements that have swapped places are *not* represented (the first address) since their *content* is unchanged. Functionally, the XML in those elements would be parsed the same manner (I assume). However, where the element has moved in the XML *tree* (Betty Croker), that is a structural change, and is detected.
