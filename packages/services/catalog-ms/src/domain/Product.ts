// =============================================
// GLAMOUR CATALOG - DOMAIN ENTITY
// =============================================
// Entidade Product representa um produto no domínio
// Seguindo os princípios de Clean Architecture
// =============================================

// Helper para converter Decimal do Prisma para number
function toNumber(value: any): number {
  if (typeof value === 'object' && value !== null && 'toNumber' in value) {
    return (value as any).toNumber();
  }
  return Number(value);
}

export interface ProductAttributes {
  name: string;
  slug: string;
  shortDescription?: string | null;
  description?: string | null;
  price: number;
  compareAtPrice?: number | null;
  costPrice?: number | null;
  stockQuantity: number;
  sku?: string | null;
  barcode?: string | null;
  brand?: string | null;
  categoryId?: number | null;
  imageUrl?: string | null;
  images?: string[] | null;
  videoUrl?: string | null;
  weightGrams?: number | null;
  dimensions?: string | null;
  isActive: boolean;
  isFeatured: boolean;
  isDigital: boolean;
  tags?: string[] | null;
  seoTitle?: string | null;
  seoDescription?: string | null;
  seoKeywords?: string | null;
}

export interface ProductVariantAttributes {
  name: string;
  sku?: string | null;
  priceAdjustment: number;
  stockQuantity: number;
  attributes?: Record<string, any> | null;
  imageUrl?: string | null;
  isActive: boolean;
}

export interface CategoryAttributes {
  name: string;
  slug: string;
  description?: string | null;
  imageUrl?: string | null;
  isActive: boolean;
  displayOrder: number;
}

// =============================================
// VALUE OBJECTS
// =============================================

export class Money {
  private constructor(private readonly amount: number) {
    if (amount < 0) {
      throw new Error('Money amount cannot be negative');
    }
  }

  static create(amount: number): Money {
    return new Money(amount);
  }

  getValue(): number {
    return this.amount;
  }

  format(currency: string = 'BRL'): string {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency,
    }).format(this.amount);
  }

  add(other: Money): Money {
    return new Money(this.amount + other.amount);
  }

  subtract(other: Money): Money {
    const result = this.amount - other.amount;
    if (result < 0) {
      throw new Error('Cannot subtract larger amount');
    }
    return new Money(result);
  }

  equals(other: Money): boolean {
    return this.amount === other.amount;
  }

  isGreaterThan(other: Money): boolean {
    return this.amount > other.amount;
  }

  isLessThan(other: Money): boolean {
    return this.amount < other.amount;
  }
}

export class Slug {
  private constructor(private readonly value: string) {}

  static create(value: string): Slug {
    const normalized = value
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');
    
    if (!normalized) {
      throw new Error('Invalid slug value');
    }
    
    return new Slug(normalized);
  }

  static fromString(value: string): Slug {
    return new Slug(value);
  }

  getValue(): string {
    return this.value;
  }

  equals(other: Slug): boolean {
    return this.value === other.value;
  }
}

// =============================================
// ENTITIES
// =============================================

export class Category {
  private constructor(
    public readonly id: number | null,
    private _name: string,
    private _slug: Slug,
    private _description: string | null,
    private _imageUrl: string | null,
    private _isActive: boolean,
    private _displayOrder: number,
    public readonly createdAt: Date,
    public readonly updatedAt: Date
  ) {}

  static create(attributes: CategoryAttributes): Category {
    const slug = Slug.create(attributes.name);
    
    return new Category(
      null,
      attributes.name,
      slug,
      attributes.description || null,
      attributes.imageUrl || null,
      attributes.isActive,
      attributes.displayOrder,
      new Date(),
      new Date()
    );
  }

  static reconstruct(
    id: number,
    attributes: CategoryAttributes,
    createdAt: Date,
    updatedAt: Date
  ): Category {
    const slug = Slug.fromString(attributes.slug);
    
    return new Category(
      id,
      attributes.name,
      slug,
      attributes.description || null,
      attributes.imageUrl || null,
      attributes.isActive,
      attributes.displayOrder,
      createdAt,
      updatedAt
    );
  }

  // Getters
  get name(): string {
    return this._name;
  }

  get slug(): Slug {
    return this._slug;
  }

  get description(): string | null {
    return this._description;
  }

  get imageUrl(): string | null {
    return this._imageUrl;
  }

  get isActive(): boolean {
    return this._isActive;
  }

  get displayOrder(): number {
    return this._displayOrder;
  }

  // Business Methods
  changeName(newName: string): void {
    if (!newName || newName.trim().length < 3) {
      throw new Error('Category name must be at least 3 characters');
    }
    this._name = newName.trim();
    this._slug = Slug.create(newName);
  }

  changeDescription(description: string | null): void {
    this._description = description;
  }

  changeImage(imageUrl: string | null): void {
    this._imageUrl = imageUrl;
  }

  activate(): void {
    this._isActive = true;
  }

  deactivate(): void {
    this._isActive = false;
  }

  changeDisplayOrder(order: number): void {
    if (order < 0) {
      throw new Error('Display order cannot be negative');
    }
    this._displayOrder = order;
  }

  toJSON() {
    return {
      id: this.id,
      name: this._name,
      slug: this._slug.getValue(),
      description: this._description,
      imageUrl: this._imageUrl,
      isActive: this._isActive,
      displayOrder: this._displayOrder,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}

export class Product {
  private constructor(
    public readonly id: number | null,
    private _name: string,
    private _slug: Slug,
    private _shortDescription: string | null,
    private _description: string | null,
    private _price: Money,
    private _compareAtPrice: Money | null,
    private _costPrice: Money | null,
    private _stockQuantity: number,
    private _sku: string | null,
    private _barcode: string | null,
    private _brand: string | null,
    private _categoryId: number | null,
    private _imageUrl: string | null,
    private _images: string[] | null,
    private _videoUrl: string | null,
    private _weightGrams: number | null,
    private _dimensions: string | null,
    private _isActive: boolean,
    private _isFeatured: boolean,
    private _isDigital: boolean,
    private _tags: string[] | null,
    private _seoTitle: string | null,
    private _seoDescription: string | null,
    private _seoKeywords: string | null,
    private _viewCount: number,
    private _salesCount: number,
    private _ratingAverage: number,
    private _ratingCount: number,
    public readonly createdAt: Date,
    public readonly updatedAt: Date
  ) {}

  static create(attributes: ProductAttributes): Product {
    const slug = Slug.create(attributes.name);
    const price = Money.create(attributes.price);
    const compareAtPrice = attributes.compareAtPrice 
      ? Money.create(attributes.compareAtPrice) 
      : null;
    const costPrice = attributes.costPrice 
      ? Money.create(attributes.costPrice) 
      : null;

    return new Product(
      null,
      attributes.name,
      slug,
      attributes.shortDescription || null,
      attributes.description || null,
      price,
      compareAtPrice,
      costPrice,
      attributes.stockQuantity,
      attributes.sku || null,
      attributes.barcode || null,
      attributes.brand || null,
      attributes.categoryId || null,
      attributes.imageUrl || null,
      attributes.images || null,
      attributes.videoUrl || null,
      attributes.weightGrams || null,
      attributes.dimensions || null,
      attributes.isActive,
      attributes.isFeatured,
      attributes.isDigital,
      attributes.tags || null,
      attributes.seoTitle || null,
      attributes.seoDescription || null,
      attributes.seoKeywords || null,
      0, // viewCount
      0, // salesCount
      0, // ratingAverage
      0, // ratingCount
      new Date(),
      new Date()
    );
  }

  // Getters
  get name(): string { return this._name; }
  get slug(): Slug { return this._slug; }
  get shortDescription(): string | null { return this._shortDescription; }
  get description(): string | null { return this._description; }
  get price(): Money { return this._price; }
  get compareAtPrice(): Money | null { return this._compareAtPrice; }
  get costPrice(): Money | null { return this._costPrice; }
  get stockQuantity(): number { return this._stockQuantity; }
  get sku(): string | null { return this._sku; }
  get barcode(): string | null { return this._barcode; }
  get brand(): string | null { return this._brand; }
  get categoryId(): number | null { return this._categoryId; }
  get imageUrl(): string | null { return this._imageUrl; }
  get images(): string[] | null { return this._images; }
  get videoUrl(): string | null { return this._videoUrl; }
  get weightGrams(): number | null { return this._weightGrams; }
  get dimensions(): string | null { return this._dimensions; }
  get isActive(): boolean { return this._isActive; }
  get isFeatured(): boolean { return this._isFeatured; }
  get isDigital(): boolean { return this._isDigital; }
  get tags(): string[] | null { return this._tags; }
  get seoTitle(): string | null { return this._seoTitle; }
  get seoDescription(): string | null { return this._seoDescription; }
  get seoKeywords(): string | null { return this._seoKeywords; }
  get viewCount(): number { return this._viewCount; }
  get salesCount(): number { return this._salesCount; }
  get ratingAverage(): number { return this._ratingAverage; }
  get ratingCount(): number { return this._ratingCount; }

  // Calculated properties
  get discountPercentage(): number | null {
    if (this._compareAtPrice && this._compareAtPrice.isGreaterThan(this._price)) {
      const discount = this._compareAtPrice.getValue() - this._price.getValue();
      return Math.round((discount / this._compareAtPrice.getValue()) * 100);
    }
    return null;
  }

  get isInStock(): boolean {
    return this._stockQuantity > 0;
  }

  get isLowStock(): boolean {
    return this._stockQuantity > 0 && this._stockQuantity <= 10;
  }

  // Business Methods
  changeName(newName: string): void {
    if (!newName || newName.trim().length < 3) {
      throw new Error('Product name must be at least 3 characters');
    }
    this._name = newName.trim();
    this._slug = Slug.create(newName);
  }

  changePrice(newPrice: number): void {
    const price = Money.create(newPrice);
    
    // Validação: preço não pode ser negativo
    if (this._costPrice && price.isLessThan(this._costPrice)) {
      throw new Error('Price cannot be less than cost price');
    }
    
    this._price = price;
  }

  updateStock(quantity: number): void {
    if (quantity < 0) {
      throw new Error('Stock quantity cannot be negative');
    }
    this._stockQuantity = quantity;
  }

  decrementStock(quantity: number = 1): void {
    if (this._stockQuantity < quantity) {
      throw new Error(`Insufficient stock. Available: ${this._stockQuantity}`);
    }
    this._stockQuantity -= quantity;
  }

  incrementStock(quantity: number): void {
    if (quantity <= 0) {
      throw new Error('Quantity to increment must be positive');
    }
    this._stockQuantity += quantity;
  }

  activate(): void {
    this._isActive = true;
  }

  deactivate(): void {
    this._isActive = false;
  }

  feature(): void {
    this._isFeatured = true;
  }

  unfeature(): void {
    this._isFeatured = false;
  }

  incrementViewCount(): void {
    this._viewCount++;
  }

  addSale(quantity: number = 1): void {
    this._salesCount += quantity;
  }

  updateRating(newRating: number): void {
    if (newRating < 0 || newRating > 5) {
      throw new Error('Rating must be between 0 and 5');
    }
    
    const totalRating = this._ratingAverage * this._ratingCount;
    this._ratingCount++;
    this._ratingAverage = (totalRating + newRating) / this._ratingCount;
  }

  toJSON() {
    return {
      id: this.id,
      name: this._name,
      slug: this._slug.getValue(),
      shortDescription: this._shortDescription,
      description: this._description,
      price: this._price.getValue(),
      formattedPrice: this._price.format(),
      compareAtPrice: this._compareAtPrice?.getValue() || null,
      formattedCompareAtPrice: this._compareAtPrice?.format() || null,
      discountPercentage: this.discountPercentage,
      costPrice: this._costPrice?.getValue() || null,
      stockQuantity: this._stockQuantity,
      isInStock: this.isInStock,
      isLowStock: this.isLowStock,
      sku: this._sku,
      barcode: this._barcode,
      brand: this._brand,
      categoryId: this._categoryId,
      imageUrl: this._imageUrl,
      images: this._images,
      videoUrl: this._videoUrl,
      weightGrams: this._weightGrams,
      dimensions: this._dimensions,
      isActive: this._isActive,
      isFeatured: this._isFeatured,
      isDigital: this._isDigital,
      tags: this._tags,
      seoTitle: this._seoTitle,
      seoDescription: this._seoDescription,
      seoKeywords: this._seoKeywords,
      viewCount: this._viewCount,
      salesCount: this._salesCount,
      ratingAverage: this._ratingAverage,
      ratingCount: this._ratingCount,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}