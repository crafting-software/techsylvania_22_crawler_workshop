# The Elixir Of Web Scraping - Techsylvania 2022

# Table of contents
1. [Introduction](#introduction)
2. [Scraping data](#scrape-data)
3. [Crawling with a Stream](#crawl-with-a-stream)
4. [Concurrency vs Parallelism](#concurrency-vs-parallelism)

## Introduction <a name="introduction"></a>

Two years back we had a client who wanted a quick solution for getting all the products on several online shops. Spcifically, we had to find all the products' UPCs on the specified websites.

## Scraping data <a name="scrape-data"></a>
- scraping a page
  - HTTPoison
  - Floki
- scraping multiple pages

## Crawling with a Stream <a name="crawl-with-a-stream"></a>
  - explain the algorithm
  - Stream
    - Eager vs Lazy
    - Stream.resource(start, next, after)

## Concurrency vs Parallelism <a name="concurrency-vs-parallelism"></a>
  - The subtle, but important difference between Concurrency and Parallelism
  - Measure execution time
  - Checking available CPUs with `:observer.start()`
  - Crawl concurrently with `Task.async_stream`
  - Embarassingly parallel?

## Conclusions <a name="conclusions"></a>
