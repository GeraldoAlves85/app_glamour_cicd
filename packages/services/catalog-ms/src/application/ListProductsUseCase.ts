// =============================================
// GLAMOUR CATALOG - APPLICATION USE CASES
// =============================================
// Casos de uso para o módulo de catálogo
// Seguindo os princípios de Clean Architecture
// =============================================

import { Product, Category } from '../domain/Product';
import prisma from '../infra/database/prisma';

// =============================================
// INTERFACES
// =============================================

export interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface ProductFilters {
  categoryId?: number;
  brand?: string;
  minPrice?: number;
  maxPrice?: number;
  isActive?: boolean;
  isFeatured?: boolean;
  inStock?: boolean;
  search?: string;
  tags?: string[];
}

export interface PaginatedResult<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrevious: boolean;
  };
}

// =============================================
// LIST PRODUCTS USE CASE
// =============================================

export class ListProductsUseCase {
  async execute(
    filters: ProductFilters = {},
    pagination: PaginationParams = {}
  ): Promise<PaginatedResult<Product>> {
    const page = Math.max(1, pagination.page || 1);
    const limit = Math.min(100, Math.max(1, pagination.limit || 20));
    const skip = (page - 1) * limit;

    // Construir where clause
    const where: any = {};

    if (filters.categoryId !== undefined) {
      where.categoryId = filters.categoryId;
    }

    if (filters.brand) {
      where.brand = filters.brand;
    }

    if (filters.isActive !== undefined) {
      where.isActive = filters.isActive;
    }

    if (filters.isFeatured !== undefined) {
      where.isFeatured = filters.isFeatured;
    }

    if (filters.inStock) {
      where.stockQuantity = { gt: 0 };
    }

    if (filters.minPrice !== undefined || filters.maxPrice !== undefined) {
      where.price = {};
      if (filters.minPrice !== undefined) {
        where.price.gte = filters.minPrice;
      }
      if (filters.maxPrice !== undefined) {
        where.price.lte = filters.maxPrice;
      }
    }

    if (filters.tags && filters.tags.length > 0) {
      // MySQL JSON search
      where.tags = {
        path: '$',
        array_contains: filters.tags,
      };
    }

    if (filters.search) {
      where.OR = [
        { name: { contains: filters.search } },
        { description: { contains: filters.search } },
        { brand: { contains: filters.search } },
        { sku: { contains: filters.search } },
      ];
    }

    // Construir orderBy
    const orderBy: any = {};
    const sortField = pagination.sortBy || 'createdAt';
    const sortOrder = pagination.sortOrder || 'desc';

    // Mapear campos de ordenação
    const sortFieldMap: Record<string, string> = {
      price: 'price',
      name: 'name',
      createdAt: 'createdAt',
      stockQuantity: 'stockQuantity',
      salesCount: 'salesCount',
      ratingAverage: 'ratingAverage',
    };

    orderBy[sortFieldMap[sortField] || 'createdAt'] = sortOrder;

    // Executar queries em paralelo para performance
    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          category: true,
        },
      }),
      prisma.product.count({ where }),
    ]);

    // Mapear para entidades de domínio
    const domainProducts = products.map((product) => {
      const attributes = {
        name: product.name,
        slug: product.slug,
        shortDescription: product.shortDescription,
        description: product.description,
        price: toNumber(product.price),
        compareAtPrice: product.compareAtPrice ? toNumber(product.compareAtPrice) : null,
        costPrice: product.costPrice,
        stockQuantity: product.stockQuantity,
        sku: product.sku,
        barcode: product.barcode,
        brand: product.brand,
        categoryId: product.categoryId,
        imageUrl: product.imageUrl,
        images: product.images as string[] | null,
        videoUrl: product.videoUrl,
        weightGrams: product.weightGrams,
        dimensions: product.dimensions,
        isActive: product.isActive,
        isFeatured: product.isFeatured,
        isDigital: product.isDigital,
        tags: product.tags as string[] | null,
        seoTitle: product.seoTitle,
        seoDescription: product.seoDescription,
        seoKeywords: product.seoKeywords,
      };

      const domainProduct = Product.reconstruct(
        product.id,
        attributes,
        product.createdAt,
        product.updatedAt
      );

      // Adicionar campos calculados manualmente
      Object.defineProperty(domainProduct, '_viewCount', { value: product.viewCount });
      Object.defineProperty(domainProduct, '_salesCount', { value: product.salesCount });
      Object.defineProperty(domainProduct, '_ratingAverage', { value: product.ratingAverage });
      Object.defineProperty(domainProduct, '_ratingCount', { value: product.ratingCount });

      return domainProduct;
    });

    const totalPages = Math.ceil(total / limit);

    return {
      data: domainProducts,
      pagination: {
        page,
        limit,
        total,
        totalPages,
        hasNext: page < totalPages,
        hasPrevious: page > 1,
      },
    };
  }
}

// =============================================
// GET PRODUCT BY ID USE CASE
// =============================================

export class GetProductByIdUseCase {
  async execute(id: number): Promise<Product | null> {
    const product = await prisma.product.findUnique({
      where: { id },
      include: {
        category: true,
        variants: true,
      },
    });

    if (!product) {
      return null;
    }

    const attributes = {
      name: product.name,
      slug: product.slug,
      shortDescription: product.shortDescription,
      description: product.description,
      price: product.price,
      compareAtPrice: product.compareAtPrice,
      costPrice: product.costPrice,
      stockQuantity: product.stockQuantity,
      sku: product.sku,
      barcode: product.barcode,
      brand: product.brand,
      categoryId: product.categoryId,
      imageUrl: product.imageUrl,
      images: product.images as string[] | null,
      videoUrl: product.videoUrl,
      weightGrams: product.weightGrams,
      dimensions: product.dimensions,
      isActive: product.isActive,
      isFeatured: product.isFeatured,
      isDigital: product.isDigital,
      tags: product.tags as string[] | null,
      seoTitle: product.seoTitle,
      seoDescription: product.seoDescription,
      seoKeywords: product.seoKeywords,
    };

    const domainProduct = Product.reconstruct(
      product.id,
      attributes,
      product.createdAt,
      product.updatedAt
    );

    // Adicionar campos calculados
    Object.defineProperty(domainProduct, '_viewCount', { value: product.viewCount });
    Object.defineProperty(domainProduct, '_salesCount', { value: product.salesCount });
    Object.defineProperty(domainProduct, '_ratingAverage', { value: product.ratingAverage });
    Object.defineProperty(domainProduct, '_ratingCount', { value: product.ratingCount });

    // Incrementar view count (fire and forget)
    prisma.product
      .update({
        where: { id },
        data: { viewCount: { increment: 1 } },
      })
      .catch(() => {
        // Ignorar erro de incremento
      });

    return domainProduct;
  }
}

// =============================================
// GET PRODUCT BY SLUG USE CASE
// =============================================

export class GetProductBySlugUseCase {
  async execute(slug: string): Promise<Product | null> {
    const product = await prisma.product.findUnique({
      where: { slug },
      include: {
        category: true,
        variants: true,
      },
    });

    if (!product) {
      return null;
    }

    const attributes = {
      name: product.name,
      slug: product.slug,
      shortDescription: product.shortDescription,
      description: product.description,
      price: product.price,
      compareAtPrice: product.compareAtPrice,
      costPrice: product.costPrice,
      stockQuantity: product.stockQuantity,
      sku: product.sku,
      barcode: product.barcode,
      brand: product.brand,
      categoryId: product.categoryId,
      imageUrl: product.imageUrl,
      images: product.images as string[] | null,
      videoUrl: product.videoUrl,
      weightGrams: product.weightGrams,
      dimensions: product.dimensions,
      isActive: product.isActive,
      isFeatured: product.isFeatured,
      isDigital: product.isDigital,
      tags: product.tags as string[] | null,
      seoTitle: product.seoTitle,
      seoDescription: product.seoDescription,
      seoKeywords: product.seoKeywords,
    };

    const domainProduct = Product.reconstruct(
      product.id,
      attributes,
      product.createdAt,
      product.updatedAt
    );

    Object.defineProperty(domainProduct, '_viewCount', { value: product.viewCount });
    Object.defineProperty(domainProduct, '_salesCount', { value: product.salesCount });
    Object.defineProperty(domainProduct, '_ratingAverage', { value: product.ratingAverage });
    Object.defineProperty(domainProduct, '_ratingCount', { value: product.ratingCount });

    // Incrementar view count
    prisma.product
      .update({
        where: { id: product.id },
        data: { viewCount: { increment: 1 } },
      })
      .catch(() => {});

    return domainProduct;
  }
}

// =============================================
// LIST CATEGORIES USE CASE
// =============================================

export class ListCategoriesUseCase {
  async execute(includeInactive: boolean = false): Promise<Category[]> {
    const where = includeInactive ? {} : { isActive: true };

    const categories = await prisma.category.findMany({
      where,
      orderBy: [{ displayOrder: 'asc' }, { name: 'asc' }],
    });

    return categories.map((cat) => {
      const attributes = {
        name: cat.name,
        slug: cat.slug,
        description: cat.description,
        imageUrl: cat.imageUrl,
        isActive: cat.isActive,
        displayOrder: cat.displayOrder,
      };

      return Category.reconstruct(
        cat.id,
        attributes,
        cat.createdAt,
        cat.updatedAt
      );
    });
  }
}

// =============================================
// GET FEATURED PRODUCTS USE CASE
// =============================================

export class GetFeaturedProductsUseCase {
  async execute(limit: number = 10): Promise<Product[]> {
    const products = await prisma.product.findMany({
      where: {
        isActive: true,
        isFeatured: true,
        stockQuantity: { gt: 0 },
      },
      take: limit,
      orderBy: [{ createdAt: 'desc' }, { salesCount: 'desc' }],
      include: {
        category: true,
      },
    });

    return products.map((product) => {
      const attributes = {
        name: product.name,
        slug: product.slug,
        shortDescription: product.shortDescription,
        description: product.description,
        price: product.price,
        compareAtPrice: product.compareAtPrice,
        costPrice: product.costPrice,
        stockQuantity: product.stockQuantity,
        sku: product.sku,
        barcode: product.barcode,
        brand: product.brand,
        categoryId: product.categoryId,
        imageUrl: product.imageUrl,
        images: product.images as string[] | null,
        videoUrl: product.videoUrl,
        weightGrams: product.weightGrams,
        dimensions: product.dimensions,
        isActive: product.isActive,
        isFeatured: product.isFeatured,
        isDigital: product.isDigital,
        tags: product.tags as string[] | null,
        seoTitle: product.seoTitle,
        seoDescription: product.seoDescription,
        seoKeywords: product.seoKeywords,
      };

      const domainProduct = Product.reconstruct(
        product.id,
        attributes,
        product.createdAt,
        product.updatedAt
      );

      Object.defineProperty(domainProduct, '_viewCount', { value: product.viewCount });
      Object.defineProperty(domainProduct, '_salesCount', { value: product.salesCount });
      Object.defineProperty(domainProduct, '_ratingAverage', { value: product.ratingAverage });
      Object.defineProperty(domainProduct, '_ratingCount', { value: product.ratingCount });

      return domainProduct;
    });
  }
}

// =============================================
// SEARCH PRODUCTS USE CASE
// =============================================

export class SearchProductsUseCase {
  async execute(
    query: string,
    pagination: PaginationParams = {}
  ): Promise<PaginatedResult<Product>> {
    const listProducts = new ListProductsUseCase();
    
    return listProducts.execute(
      {
        search: query,
        isActive: true,
        inStock: true,
      },
      pagination
    );
  }
}