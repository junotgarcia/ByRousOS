/** Skeleton types for catalogue & stock — replace with DB models (e.g. Prisma) later. */
export interface SkuLike {
  id: string;
  name: string;
  quantityOnHand?: number;
}
