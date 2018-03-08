for filename in *.tif
do

  # Layer name and title configuration #######

  # R2AWA_30012018_315077_STLC00GODP_RPC.tif

  aux=${filename:6:15}

  orbit_point="${aux:9:6}"
  orbit_point="${orbit_point:0:3}_${orbit_point:3:3}"

  file_date="${aux:0:8}"

  bands="${filename:33:3}"

  layer_name="R2AWA_${orbit_point}_${file_date}"

  storage_name=${layer_name}_store

  orbit_point_title="${orbit_point:0:3} ${orbit_point:4:3}"

  layer_title="AWA ${orbit_point_title} ${file_date}"

  bands_abstract="Composicao de bandas R:${bands:0:1} G:${bands:1:1} B:${bands:2:1}"

  layer_abstract="Imagem AWIFS de ${file_date:0:2}-${file_date:2:2}-${file_date:4:4} na orbita-ponto ${orbit_point_title} com contraste. ${bands_abstract}."

  # File name configuration ###################

  filepath="$(pwd)/"

  filename="${filepath}${filename}"


  # REST params configuration ##################
  
  storage_xml="<coverageStore>
                  <name>${storage_name}</name>
                  <workspace>terraamazon</workspace>
                  <enabled>true</enabled>
                  <type>GeoTIFF</type>
                  <url>${filename}</url>
               </coverageStore>"

  layer_xml="<coverage>
                <name>${layer_name}</name>
                <title>${layer_title}</title>
                <abstract>${layer_abstract}</abstract>
                <srs>EPSG:4326</srs>
                <projectionPolicy>REPROJECT_TO_DECLARED</projectionPolicy>
                <dimensions>
                  <coverageDimension>
                    <name>RED_BAND</name>
                    <description>GridSampleDimension[-Infinity,Infinity]</description>
                    <range>
                      <min>0.0</min>
                      <max>255.0</max>
                    </range>
                    <nullValues>
                       <double>0.0</double>
                    </nullValues>
                    <unit>W.m-2.Sr-1</unit>
                    <dimensionType>
                      <name>UNSIGNED_8BITS</name>
                    </dimensionType>
                  </coverageDimension>
                  <coverageDimension>
                    <name>GREEN_BAND</name>
                    <description>GridSampleDimension[-Infinity,Infinity]</description>
                    <range>
                      <min>0.0</min>
                      <max>255.0</max>
                    </range>
                    <nullValues>
                      <double>0.0</double>
                    </nullValues>
                    <unit>W.m-2.Sr-1</unit>
                    <dimensionType>
                      <name>UNSIGNED_8BITS</name>
                    </dimensionType>
                  </coverageDimension>
                  <coverageDimension>
                    <name>BLUE_BAND</name>
                    <description>GridSampleDimension[-Infinity,Infinity]</description>
                    <range>
                      <min>0.0</min>
                      <max>255.0</max>
                    </range>
                    <nullValues><double>0.0</double></nullValues>
                    <unit>W.m-2.Sr-1</unit>
                    <dimensionType>
                      <name>UNSIGNED_8BITS</name>
                    </dimensionType>
                  </coverageDimension>
                </dimensions>
                <parameters>
                  <entry>
                    <string>SUGGESTED_TILE_SIZE</string>
                    <string>512,512</string>
                  </entry>
                </parameters>
              </coverage>"

  #<entry>
    #<string>InputTransparentColor</string>
    #<string>#000000</string>
  #</entry>

  # REST URL configuration ######################

  #  http://localhost:8080/geoserver/

  create_storage_url="http://localhost:8080/geoserver/rest/workspaces/terraamazon/coveragestores"

  remove_storage_url="${create_storage_url}/${storage_name}?recurse=true"

  create_layer_url="${create_storage_url}/${storage_name}/coverages"

  create_storage_url="${create_storage_url}?configure=all"
  
  # REST requests ###############################
  
  # Por segurança, o coverage store é removido para o caso de já existir uma publicação anterior.
  curl -v -u admin:geoserver -XDELETE ${remove_storage_url}

  # Cria o coverage store
  curl -u admin:geoserver -v -XPOST -H 'Content-type: text/xml' -d "${storage_xml}" ${create_storage_url}

  # Publica o layer
  curl -u admin:geoserver -v -XPOST -H 'Content-type: text/xml' -d "${layer_xml}" ${create_layer_url}
done