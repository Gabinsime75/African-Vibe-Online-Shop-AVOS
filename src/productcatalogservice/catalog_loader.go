// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"context"
	"os"
	"strings"
	"time"

	pb "github.com/Gabinsime75/African-Vibe-Online-Shop-AVOS/src/productcatalogservice/genproto"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"google.golang.org/protobuf/encoding/protojson"
)

const defaultProductsTable = "products"

func loadCatalog(catalog *pb.ListProductsResponse) error {
	catalogMutex.Lock()
	defer catalogMutex.Unlock()

	if strings.TrimSpace(os.Getenv("DATABASE_URL")) != "" {
		return loadCatalogFromAurora(catalog)
	}

	return loadCatalogFromLocalFile(catalog)
}

func loadCatalogFromLocalFile(catalog *pb.ListProductsResponse) error {
	log.Info("loading catalog from local products.json file...")

	catalogJSON, err := os.ReadFile("products.json")
	if err != nil {
		log.Warnf("failed to open product catalog json file: %v", err)
		return err
	}

	if err := protojson.Unmarshal(catalogJSON, catalog); err != nil {
		log.Warnf("failed to parse the catalog JSON: %v", err)
		return err
	}

	log.Info("successfully parsed product catalog json")
	return nil
}

func loadCatalogFromAurora(catalog *pb.ListProductsResponse) error {
	log.Info("loading AVOS catalog from Aurora PostgreSQL...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	pool, err := pgxpool.New(ctx, os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Warnf("failed to create Aurora connection pool: %v", err)
		return err
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Warnf("failed to connect to Aurora PostgreSQL: %v", err)
		return err
	}

	tableName := strings.TrimSpace(os.Getenv("PRODUCTS_TABLE"))
	if tableName == "" {
		tableName = defaultProductsTable
	}

	query := "SELECT id, name, description, picture, price_usd_currency_code, " +
		"price_usd_units, price_usd_nanos, categories FROM " + pgx.Identifier{tableName}.Sanitize()
	rows, err := pool.Query(ctx, query)
	if err != nil {
		log.Warnf("failed to query Aurora product catalog: %v", err)
		return err
	}
	defer rows.Close()

	catalog.Products = catalog.Products[:0]
	for rows.Next() {
		product := &pb.Product{}
		product.PriceUsd = &pb.Money{}

		var categories string
		err = rows.Scan(&product.Id, &product.Name, &product.Description,
			&product.Picture, &product.PriceUsd.CurrencyCode, &product.PriceUsd.Units,
			&product.PriceUsd.Nanos, &categories)
		if err != nil {
			log.Warnf("failed to scan query result row: %v", err)
			return err
		}
		for _, category := range strings.Split(strings.ToLower(categories), ",") {
			if category = strings.TrimSpace(category); category != "" {
				product.Categories = append(product.Categories, category)
			}
		}

		catalog.Products = append(catalog.Products, product)
	}

	if err := rows.Err(); err != nil {
		log.Warnf("failed while reading Aurora product rows: %v", err)
		return err
	}

	log.Infof("successfully loaded %d AVOS products from Aurora PostgreSQL", len(catalog.Products))
	return nil
}
