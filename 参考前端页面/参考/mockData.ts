import { Stall, Order, Review, MenuItem } from './types';

export const MOCK_STALLS: Stall[] = [
  {
    id: 1,
    name: "Uncle Fatty's Fried Rice",
    category: "Rice",
    rating: 4.8,
    distance: 50,
    waitTime: 15,
    isOpen: true,
    image: "https://picsum.photos/200/200?random=1",
    tags: ["Spicy", "Large Portion", "Late Night"],
    description: "The most famous fried rice on campus. Generous portions!"
  },
  {
    id: 2,
    name: "Busy Lemon Tea",
    category: "Drink",
    rating: 4.6,
    distance: 120,
    waitTime: 5,
    isOpen: true,
    image: "https://picsum.photos/200/200?random=2",
    tags: ["Refreshing", "Hand-mashed", "Sweet"],
    description: "Hand-mashed perfume lemon tea. Perfect for summer."
  },
  {
    id: 3,
    name: "Granny's Beef Offal",
    category: "Snack",
    rating: 4.9,
    distance: 300,
    waitTime: 20,
    isOpen: true,
    image: "https://picsum.photos/200/200?random=3",
    tags: ["Traditional", "Savory", "Meat"],
    description: "Authentic Cantonese style beef offal stew."
  },
  {
    id: 4,
    name: "Midnight Skewers",
    category: "BBQ",
    rating: 4.5,
    distance: 500,
    waitTime: 0,
    isOpen: false,
    image: "https://picsum.photos/200/200?random=4",
    tags: ["Oily", "Spicy", "Beer Mate"],
    description: "Best choice for late night cravings."
  }
];

export const MOCK_MENU: Record<number, MenuItem[]> = {
  1: [
    { id: 101, name: "Supreme Beef Fried Rice", price: 18, sales: 120, image: "https://picsum.photos/100/100?food=1" },
    { id: 102, name: "Spicy Pork Fried Rice", price: 15, sales: 90, image: "https://picsum.photos/100/100?food=2" },
    { id: 103, name: "Yangzhou Fried Rice", price: 12, sales: 200, image: "https://picsum.photos/100/100?food=3" }
  ],
  2: [
    { id: 201, name: "Signature Lemon Tea", price: 14, sales: 300, image: "https://picsum.photos/100/100?drink=1" },
    { id: 202, name: "Mango Pomelo Sago", price: 18, sales: 150, image: "https://picsum.photos/100/100?drink=2" }
  ]
};

export const MOCK_ORDERS: Order[] = [
  {
    id: "ORD-2023-8821",
    stallName: "Uncle Fatty's Fried Rice",
    stallImage: "https://picsum.photos/200/200?random=1",
    items: ["Supreme Beef Fried Rice x1", "Coke Zero x1"],
    total: 21.00,
    status: "preparing",
    pickupCode: "F-102",
    orderTime: "18:30",
    estimatedTime: "15 mins"
  },
  {
    id: "ORD-2023-8755",
    stallName: "Busy Lemon Tea",
    stallImage: "https://picsum.photos/200/200?random=2",
    items: ["Signature Lemon Tea x2"],
    total: 28.00,
    status: "completed",
    pickupCode: "L-099",
    orderTime: "12:15"
  }
];

export const MOCK_REVIEWS: Review[] = [
  { id: 1, user: "FoodieKing", avatar: "https://picsum.photos/50/50?random=10", content: "The portion is huge! Can't finish it alone.", rating: 5, tags: ["Recommended"] },
  { id: 2, user: "LateNightOwl", avatar: "https://picsum.photos/50/50?random=11", content: "A bit too oily for me, but tastes good.", rating: 4, tags: ["Oily"] },
  { id: 3, user: "Alice", avatar: "https://picsum.photos/50/50?random=12", content: "Wait time was longer than expected.", rating: 3, tags: ["Avoid Peak Hours"] }
];
