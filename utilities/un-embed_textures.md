A tool for un-embed textures that are **Hardcoded** in a BSP File.

Downlaod the tool [BSPTexR](https://github.com/Litude/BSPTexRM)

The use of this and any wad editor [wally](https://gamebanana.com/tools/4774) And Ripent

You can safely extract wads from maps (ripent), merge them (wally), and remove the embedded textures from the maps (BSPTexRM)


- 1 Extract wads from maps using ripent command line "ripent -textureexport mapname"

- 2 Create folder named A

- 3 Export the default textures from default wads (halflife, opfor, etc etc) to png, tga, jpg or any other format available. in folder A

- 4 Export the map textures to a folder B

- 5 Move all the default textures to the folder B then replace the ones with same names

- 6 Now just press CTRL+Z. the default textures will return to folder A while only the map custom ones will keep in folder B.

- 7 Create new wad with wally with all those custom ones.

- 8 Use this tool to delete embeeded textures. 
command line
```
bsptexrm mapname
```

- 9 Add the wad into the bsp wordspawn keyvalue.

**NOTE:**
Since the new bsp will not longer have embeeded textures it will have a less size and new BSP will difier from the old BSP.