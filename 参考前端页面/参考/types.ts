export interface Stall {
  id: number;
  name: string;
  category: string;
  rating: number;
  distance: number; // in meters
  waitTime: number; // in minutes
  isOpen: boolean;
  image: string;
  tags: string[];
  description: string;
}

export interface MenuItem {
  id: number;
  name: string;
  price: number;
  sales: number;
  image: string;
}

export interface Order {
  id: string;
  stallName: string;
  stallImage: string;
  items: string[];
  total: number;
  status: 'pending' | 'preparing' | 'ready' | 'completed';
  pickupCode: string;
  orderTime: string;
  estimatedTime?: string;
}

export interface Review {
  id: number;
  user: string;
  avatar: string;
  content: string;
  rating: number;
  images?: string[];
  tags?: string[]; // e.g. "Recommended", "Avoid"
}
