# 30_salvar.R

saveRDS(gdf, file = "data/limpo/gdf.rds")
write_csv(gdf, "data/limpo/gdf.csv")
st_write(gdf, "data/limpo/gdf.geojson")
st_write(gdf, "data/limpo/gdf.gpkg")
