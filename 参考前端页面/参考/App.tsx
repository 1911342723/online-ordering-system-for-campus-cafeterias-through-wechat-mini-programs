import React, { useState, useEffect, useRef } from 'react';
import { MOCK_STALLS, MOCK_ORDERS, MOCK_REVIEWS, MOCK_MENU } from './mockData';
import { Stall, Order, MenuItem } from './types';
import { getFoodRecommendation, summarizeReviews } from './geminiService';

// --- Icons ---
// Using FontAwesome classes (loaded in index.html) for simplicity in this generated file.
// Ideally, we would use 'lucide-react' or 'react-icons', but FA is easy via CDN.

// --- Components ---

const NavBar = ({ activeTab, onSwitch }: { activeTab: string; onSwitch: (t: string) => void }) => {
  const navItems = [
    { id: 'home', icon: 'fa-house', label: 'Home' },
    { id: 'radar', icon: 'fa-compass', label: 'Radar' },
    { id: 'community', icon: 'fa-comments', label: 'Buzz' },
    { id: 'order', icon: 'fa-receipt', label: 'Orders' },
    { id: 'profile', icon: 'fa-user', label: 'Me' },
  ];

  return (
    <div className="absolute bottom-0 left-0 w-full bg-white/90 backdrop-blur-md border-t border-gray-100 pb-6 pt-3 px-4 z-40">
      <div className="flex justify-between items-center">
        {navItems.map((item) => {
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              onClick={() => onSwitch(item.id)}
              className={`flex flex-col items-center gap-1 flex-1 transition-all duration-300 ${isActive ? 'text-brand-darkBlue transform -translate-y-1' : 'text-gray-400'}`}
            >
              <div className={`w-10 h-8 rounded-xl flex items-center justify-center text-lg transition-colors ${isActive ? 'bg-blue-50' : ''}`}>
                <i className={`fa-solid ${item.icon}`}></i>
              </div>
              <span className={`text-[10px] font-bold ${isActive ? 'opacity-100' : 'opacity-80'}`}>{item.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
};

const Header = ({ title }: { title?: string }) => (
  <div className="pt-12 pb-4 px-5 bg-white sticky top-0 z-30 shadow-sm flex items-center justify-between">
    <div className="flex items-center gap-2">
      <i className="fa-solid fa-location-dot text-brand-blue"></i>
      <span className="font-bold text-gray-800 text-lg">{title || "Campus CBD · North Gate"}</span>
      <i className="fa-solid fa-chevron-down text-xs text-gray-400"></i>
    </div>
    <div className="w-8 h-8 rounded-full bg-brand-yellow/20 flex items-center justify-center text-brand-yellow">
      <i className="fa-solid fa-bell"></i>
    </div>
  </div>
);

// --- VIEW: HOME ---
const HomeView = ({ onOpenStall }: { onOpenStall: (id: number) => void }) => {
  const [mood, setMood] = useState("");
  const [aiResult, setAiResult] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const handleConsultAI = async () => {
    if (!mood.trim()) return;
    setLoading(true);
    setAiResult(null);
    const stallsStr = MOCK_STALLS.map(s => `${s.name} (${s.tags.join(',')})`).join(", ");
    const result = await getFoodRecommendation(mood, stallsStr);
    setAiResult(result);
    setLoading(false);
  };

  return (
    <div className="pb-24">
      <Header />
      
      {/* Search */}
      <div className="px-4 mt-2">
        <div className="relative">
          <input 
            type="text" 
            placeholder="Search for fried rice, drinks..." 
            className="w-full bg-gray-100 rounded-full py-2.5 px-10 text-sm focus:outline-none focus:ring-2 focus:ring-brand-blue/50"
          />
          <i className="fa-solid fa-search absolute left-4 top-3 text-gray-400 text-sm"></i>
        </div>
      </div>

      {/* Banner */}
      <div className="px-4 mt-4">
        <div className="w-full h-36 rounded-2xl bg-gradient-to-r from-brand-blue to-cyan-300 relative overflow-hidden shadow-lg p-6 flex items-center">
          <div className="relative z-10 text-white">
            <div className="text-[10px] font-bold bg-white text-brand-blue inline-block px-2 py-0.5 rounded mb-2 shadow-sm">NEW</div>
            <h2 className="text-2xl font-black mb-1">Night Market</h2>
            <p className="text-sm opacity-90">Collect stamps for free merch!</p>
          </div>
          <i className="fa-solid fa-burger text-white opacity-20 text-8xl absolute -right-4 -bottom-4 rotate-12"></i>
        </div>
      </div>

      {/* AI Section */}
      <div className="px-4 mt-6">
        <div className="bg-white rounded-xl border border-purple-100 shadow-sm p-4 relative overflow-hidden">
          <div className="absolute top-0 right-0 w-16 h-16 bg-purple-50 rounded-bl-full -mr-4 -mt-4 z-0"></div>
          <div className="relative z-10">
            <div className="flex items-center gap-2 mb-2">
              <span className="text-lg animate-pulse">✨</span>
              <h3 className="font-bold text-purple-700">Food Oracle</h3>
            </div>
            <p className="text-xs text-gray-500 mb-3">Not sure what to eat? Tell me your mood.</p>
            <div className="flex gap-2">
              <input 
                value={mood}
                onChange={(e) => setMood(e.target.value)}
                placeholder="e.g., I failed my exam..." 
                className="flex-1 bg-gray-50 border border-purple-100 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:border-purple-400"
              />
              <button 
                onClick={handleConsultAI}
                disabled={loading}
                className="bg-purple-500 text-white px-4 py-1.5 rounded-lg text-sm font-bold shadow-md active:scale-95 transition-transform"
              >
                {loading ? <i className="fa-solid fa-spinner fa-spin"></i> : 'Ask'}
              </button>
            </div>
            {aiResult && (
              <div className="mt-3 p-3 bg-purple-50 rounded-lg text-sm text-purple-800 border border-purple-100 animate-in fade-in slide-in-from-top-2">
                <i className="fa-solid fa-robot mr-2"></i> {aiResult}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Stall List */}
      <div className="px-4 mt-6 space-y-4">
        <h3 className="font-bold text-gray-700 text-lg">Popular Stalls</h3>
        {MOCK_STALLS.map(stall => (
          <div 
            key={stall.id} 
            onClick={() => onOpenStall(stall.id)}
            className={`bg-white rounded-xl p-3 flex gap-4 shadow-sm border border-gray-100 active:scale-[0.98] transition-transform ${!stall.isOpen ? 'opacity-60 grayscale' : ''}`}
          >
            <div className="w-20 h-20 rounded-lg bg-gray-200 overflow-hidden relative shrink-0">
               <img src={stall.image} alt={stall.name} className="w-full h-full object-cover" />
               {!stall.isOpen && <div className="absolute inset-0 bg-black/50 flex items-center justify-center text-white text-xs font-bold">CLOSED</div>}
            </div>
            <div className="flex-1">
              <div className="flex justify-between items-start">
                <h4 className="font-bold text-gray-800 line-clamp-1">{stall.name}</h4>
                <span className="text-xs text-brand-darkBlue bg-blue-50 px-1.5 py-0.5 rounded">{stall.distance}m</span>
              </div>
              <div className="flex items-center gap-1 my-1">
                <span className="text-xs text-brand-yellow font-bold"><i className="fa-solid fa-star"></i> {stall.rating}</span>
                <span className="text-gray-300 mx-1">|</span>
                <span className="text-xs text-gray-500">Wait: {stall.waitTime}m</span>
              </div>
              <div className="flex gap-1 mt-2 flex-wrap">
                {stall.tags.slice(0, 2).map(tag => (
                   <span key={tag} className="text-[10px] bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full">{tag}</span>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// --- VIEW: RADAR ---
const RadarView = () => {
  return (
    <div className="w-full h-full bg-slate-900 relative overflow-hidden flex items-center justify-center">
      <div className="absolute top-12 left-6 z-20">
        <h1 className="text-3xl font-black text-white italic tracking-tighter">RADAR</h1>
        <p className="text-brand-blue text-xs font-mono animate-pulse">SCANNING AREA...</p>
      </div>

      {/* Radar Circles */}
      <div className="absolute w-[600px] h-[600px] border border-brand-blue/10 rounded-full animate-radar-ping"></div>
      <div className="absolute w-[400px] h-[400px] border border-brand-blue/20 rounded-full animate-radar-ping delay-75"></div>
      <div className="absolute w-[200px] h-[200px] border border-brand-blue/30 rounded-full animate-radar-ping delay-150"></div>
      
      {/* User Dot */}
      <div className="w-4 h-4 bg-brand-blue rounded-full shadow-[0_0_20px_rgba(56,189,248,0.8)] z-10 relative">
        <div className="absolute -inset-4 bg-brand-blue/20 rounded-full animate-ping"></div>
      </div>

      {/* Stalls Markers (Simulated) */}
      <div className="absolute top-1/3 left-1/4 animate-bounce duration-[3000ms]">
         <div className="flex flex-col items-center gap-1 group">
            <div className="w-10 h-10 bg-white rounded-full flex items-center justify-center text-lg shadow-lg border-2 border-brand-yellow">🍱</div>
            <span className="text-[10px] text-white bg-black/50 px-2 py-0.5 rounded backdrop-blur-sm opacity-0 group-hover:opacity-100 transition-opacity">Uncle Fatty</span>
         </div>
      </div>
      
      <div className="absolute bottom-1/3 right-1/4 animate-bounce duration-[4000ms]">
         <div className="flex flex-col items-center gap-1 group">
            <div className="w-10 h-10 bg-white rounded-full flex items-center justify-center text-lg shadow-lg border-2 border-green-400">🥤</div>
            <span className="text-[10px] text-white bg-black/50 px-2 py-0.5 rounded backdrop-blur-sm opacity-0 group-hover:opacity-100 transition-opacity">Lemon Tea</span>
         </div>
      </div>
    </div>
  );
};

// --- VIEW: ORDER (Requested specific styling) ---
const OrderView = () => {
  return (
    <div className="pb-24 bg-brand-bg min-h-full">
      <div className="pt-12 px-5 pb-4 bg-white shadow-sm sticky top-0 z-20">
        <h1 className="text-xl font-bold text-gray-800">My Orders</h1>
      </div>

      <div className="p-4 space-y-4">
        {/* Active Order Card */}
        {MOCK_ORDERS.filter(o => o.status !== 'completed').map(order => (
          <div key={order.id} className="bg-white rounded-2xl shadow-lg border-2 border-blue-100 overflow-hidden relative">
            {/* Status Ribbon */}
            <div className="absolute top-0 right-0 bg-brand-blue text-white text-xs px-4 py-1.5 rounded-bl-xl font-bold uppercase tracking-wider">
              {order.status}
            </div>

            <div className="p-5">
              <div className="flex gap-4">
                <img src={order.stallImage} className="w-14 h-14 rounded-lg bg-gray-100 object-cover" />
                <div>
                  <h3 className="font-bold text-gray-800 text-lg leading-tight">{order.stallName}</h3>
                  <p className="text-xs text-gray-500 mt-1">Est. wait: <span className="text-brand-darkBlue font-bold">{order.estimatedTime}</span></p>
                </div>
              </div>

              {/* Progress Bar (Fake) */}
              <div className="mt-5 mb-2">
                 <div className="w-full h-1.5 bg-gray-100 rounded-full overflow-hidden">
                   <div className="h-full bg-brand-blue w-2/3 animate-pulse"></div>
                 </div>
                 <div className="flex justify-between text-[10px] text-gray-400 mt-1">
                   <span>Order Placed</span>
                   <span className="text-brand-blue font-bold">Preparing...</span>
                   <span>Ready</span>
                 </div>
              </div>

              <div className="border-t border-dashed border-gray-200 my-4"></div>

              <div className="flex justify-between items-center">
                <div>
                  <p className="text-xs text-gray-400 mb-1 font-bold uppercase">Pickup Code</p>
                  <p className="text-4xl font-black text-gray-800 tracking-tighter">{order.pickupCode}</p>
                </div>
                <div className="bg-gray-50 p-2 rounded-lg border border-gray-100">
                  <i className="fa-solid fa-qrcode text-4xl text-gray-800"></i>
                </div>
              </div>
            </div>

            <div className="bg-blue-50/50 px-5 py-3 flex justify-between items-center border-t border-blue-50">
               <div className="flex flex-col">
                  <span className="text-[10px] text-gray-400">Total</span>
                  <span className="text-sm font-bold text-gray-800">${order.total.toFixed(2)}</span>
               </div>
               <button className="text-xs bg-white border border-brand-blue text-brand-blue font-bold px-4 py-1.5 rounded-full hover:bg-brand-blue hover:text-white transition-colors">
                 Contact Shop
               </button>
            </div>
          </div>
        ))}

        {/* History Orders */}
        <h4 className="text-sm font-bold text-gray-400 mt-6 mb-2 ml-1">History</h4>
        {MOCK_ORDERS.filter(o => o.status === 'completed').map(order => (
          <div key={order.id} className="bg-white rounded-xl border border-gray-100 p-4 opacity-80 hover:opacity-100 transition-opacity">
            <div className="flex justify-between mb-2">
              <h3 className="font-bold text-gray-700">{order.stallName}</h3>
              <span className="text-xs text-gray-400 bg-gray-100 px-2 py-0.5 rounded">Completed</span>
            </div>
            <p className="text-sm text-gray-500 line-clamp-1">{order.items.join(', ')}</p>
            <div className="mt-3 flex gap-2">
              <button className="flex-1 py-1.5 border border-gray-200 rounded-lg text-xs font-bold text-gray-600">Reorder</button>
              <button className="flex-1 py-1.5 bg-brand-yellow/10 text-brand-yellow rounded-lg text-xs font-bold">Rate</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// --- VIEW: COMMUNITY ---
const CommunityView = () => {
  return (
    <div className="pb-24 bg-gray-50 min-h-full">
      <Header title="Buzz Feed" />
      <div className="px-4 mt-4 columns-2 gap-4 space-y-4">
        {MOCK_REVIEWS.map((review, idx) => (
          <div key={idx} className="break-inside-avoid bg-white rounded-xl overflow-hidden shadow-sm border border-gray-100">
             <div className="h-32 bg-gray-200 relative">
               <img src={`https://picsum.photos/200/200?random=${20+idx}`} className="w-full h-full object-cover" />
               {review.tags && review.tags[0] && (
                 <span className="absolute top-2 left-2 bg-brand-yellow text-white text-[10px] px-2 py-0.5 rounded font-bold shadow-sm">{review.tags[0]}</span>
               )}
             </div>
             <div className="p-3">
               <p className="text-xs font-bold text-gray-800 line-clamp-2 leading-relaxed">{review.content}</p>
               <div className="flex items-center justify-between mt-3">
                 <div className="flex items-center gap-1.5">
                   <img src={review.avatar} className="w-4 h-4 rounded-full" />
                   <span className="text-[10px] text-gray-400 truncate max-w-[50px]">{review.user}</span>
                 </div>
                 <div className="text-[10px] text-gray-400"><i className="fa-regular fa-heart"></i> {10 + idx}</div>
               </div>
             </div>
          </div>
        ))}
      </div>
    </div>
  );
};

// --- VIEW: PROFILE ---
const ProfileView = () => (
    <div className="pb-24 bg-white min-h-full">
         <div className="w-full h-48 bg-gradient-to-br from-brand-blue to-purple-400 relative">
             <div className="absolute bottom-0 w-full h-8 bg-white rounded-t-[40px]"></div>
         </div>
         <div className="px-5 relative -mt-16">
             <div className="bg-white rounded-2xl shadow-xl p-4 flex flex-col items-center relative border border-gray-50">
                 <div className="w-20 h-20 rounded-full border-4 border-white shadow-md relative -mt-12 bg-gray-200">
                     <img src="https://api.dicebear.com/7.x/avataaars/svg?seed=Felix" className="w-full h-full rounded-full" />
                 </div>
                 <h2 className="text-xl font-bold text-gray-800 mt-2">Student_Felix</h2>
                 <div className="flex items-center gap-2 mt-1">
                     <span className="px-2 py-0.5 bg-brand-yellow/20 text-yellow-700 text-[10px] rounded-full font-bold">Lvl.5 Foodie</span>
                 </div>
                 
                 <div className="flex w-full justify-around mt-6 border-t border-gray-100 pt-4">
                     <div className="text-center">
                         <div className="text-lg font-black text-gray-800">12</div>
                         <div className="text-xs text-gray-400">Favs</div>
                     </div>
                     <div className="text-center">
                         <div className="text-lg font-black text-gray-800">3</div>
                         <div className="text-xs text-gray-400">Coupons</div>
                     </div>
                     <div className="text-center">
                         <div className="text-lg font-black text-gray-800">158</div>
                         <div className="text-xs text-gray-400">Points</div>
                     </div>
                 </div>
             </div>
         </div>
         <div className="px-5 mt-6 space-y-3">
             <div className="bg-gray-50 p-4 rounded-xl flex items-center justify-between">
                 <div className="flex items-center gap-3">
                     <div className="w-8 h-8 rounded-full bg-white text-brand-blue flex items-center justify-center shadow-sm"><i className="fa-solid fa-wallet"></i></div>
                     <span className="font-bold text-gray-700 text-sm">Wallet</span>
                 </div>
                 <i className="fa-solid fa-chevron-right text-gray-300 text-xs"></i>
             </div>
             <div className="bg-gray-50 p-4 rounded-xl flex items-center justify-between">
                 <div className="flex items-center gap-3">
                     <div className="w-8 h-8 rounded-full bg-white text-green-500 flex items-center justify-center shadow-sm"><i className="fa-solid fa-location-dot"></i></div>
                     <span className="font-bold text-gray-700 text-sm">Addresses</span>
                 </div>
                 <i className="fa-solid fa-chevron-right text-gray-300 text-xs"></i>
             </div>
         </div>
    </div>
);

// --- COMPONENT: STALL DETAIL MODAL ---
const StallDetailModal = ({ stallId, onClose }: { stallId: number | null; onClose: () => void }) => {
  const [summary, setSummary] = useState<string | null>(null);
  const [isSummarizing, setIsSummarizing] = useState(false);
  const stall = MOCK_STALLS.find(s => s.id === stallId);
  const menu = stallId ? MOCK_MENU[stallId] : [];

  const handleSummarize = async () => {
    setIsSummarizing(true);
    const reviewsStr = JSON.stringify(MOCK_REVIEWS.map(r => r.content));
    const result = await summarizeReviews(reviewsStr);
    setSummary(result);
    setIsSummarizing(false);
  };

  if (!stallId || !stall) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center pointer-events-none">
      <div className="absolute inset-0 bg-black/60 backdrop-blur-sm pointer-events-auto transition-opacity" onClick={onClose}></div>
      <div className="bg-white w-full h-[85vh] rounded-t-3xl relative pointer-events-auto shadow-2xl flex flex-col animate-in slide-in-from-bottom-5">
        
        {/* Drag Handle */}
        <div className="w-full flex justify-center pt-3 pb-1" onClick={onClose}>
            <div className="w-12 h-1.5 bg-gray-300 rounded-full"></div>
        </div>

        {/* Header */}
        <div className="px-5 pb-4 border-b border-gray-100 shrink-0">
             <div className="flex justify-between items-start mt-2">
                 <div>
                     <h2 className="text-2xl font-black text-gray-800">{stall.name}</h2>
                     <div className="flex items-center gap-2 mt-1 text-sm">
                         <span className="text-brand-yellow"><i className="fa-solid fa-star"></i> {stall.rating}</span>
                         <span className="text-gray-300">|</span>
                         <span className="text-gray-500">Monthly Sold 800+</span>
                     </div>
                 </div>
                 <img src={stall.image} className="w-16 h-16 rounded-xl bg-gray-100 object-cover -mt-6 border-4 border-white shadow-md" />
             </div>
             
             {/* AI Summary Widget */}
             <div 
               onClick={handleSummarize}
               className="mt-4 bg-gradient-to-r from-blue-50 to-indigo-50 p-2.5 rounded-lg border border-blue-100 cursor-pointer active:scale-[0.99] transition-transform"
             >
                <div className="flex items-center justify-between">
                   <div className="flex items-center gap-2 text-xs">
                       <span className="bg-brand-blue text-white px-1.5 py-0.5 rounded font-bold text-[10px]">AI</span>
                       <span className="text-brand-darkBlue font-bold">Too many reviews?</span>
                   </div>
                   <div className="text-xs text-brand-blue font-bold flex items-center gap-1">
                       Summarize <i className="fa-solid fa-chevron-right text-[10px]"></i>
                   </div>
                </div>
                {isSummarizing && <div className="mt-2 text-xs text-gray-500"><i className="fa-solid fa-circle-notch fa-spin"></i> Analyzing tastes...</div>}
                {summary && (
                  <div className="mt-2 text-xs text-gray-700 bg-white/60 p-2 rounded whitespace-pre-line border border-white/50">
                    {summary}
                  </div>
                )}
             </div>
        </div>

        {/* Menu List */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
           {menu?.map(item => (
             <div key={item.id} className="flex gap-3">
                <img src={item.image} className="w-20 h-20 rounded-lg bg-gray-100 object-cover" />
                <div className="flex-1 flex flex-col justify-between py-1">
                    <h4 className="font-bold text-gray-800">{item.name}</h4>
                    <div className="text-xs text-gray-400">Sold {item.sales}</div>
                    <div className="flex justify-between items-end">
                        <span className="font-bold text-red-500 text-lg"><span className="text-xs">¥</span>{item.price}</span>
                        <button className="w-6 h-6 bg-brand-blue rounded-full text-white flex items-center justify-center shadow-md active:scale-90 transition-transform">
                            <i className="fa-solid fa-plus text-xs"></i>
                        </button>
                    </div>
                </div>
             </div>
           ))}
           {!menu && <div className="text-center text-gray-400 mt-10">Menu loading...</div>}
        </div>

        {/* Cart Bar */}
        <div className="p-4 border-t border-gray-100 bg-white pb-8 shrink-0">
             <div className="bg-gray-900 text-white rounded-full h-14 flex items-center justify-between px-2 pr-2 shadow-xl relative">
                 <div className="relative -top-4 left-2">
                     <div className="w-14 h-14 bg-brand-yellow rounded-full flex items-center justify-center text-gray-900 border-4 border-gray-900 relative">
                         <i className="fa-solid fa-cart-shopping text-xl"></i>
                         <div className="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] w-5 h-5 flex items-center justify-center rounded-full border-2 border-gray-900">1</div>
                     </div>
                 </div>
                 <div className="flex-1 pl-6">
                     <div className="text-lg font-bold">¥18.00</div>
                     <div className="text-[10px] text-gray-400">Pickup Only • No Delivery Fee</div>
                 </div>
                 <button className="bg-brand-blue h-10 px-6 rounded-full font-bold text-sm hover:bg-brand-darkBlue transition-colors">
                     Checkout
                 </button>
             </div>
        </div>
      </div>
    </div>
  );
};

// --- APP ROOT ---
const App = () => {
  const [activeTab, setActiveTab] = useState('home');
  const [selectedStallId, setSelectedStallId] = useState<number | null>(null);

  // Mobile frame wrapper for web preview
  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-200">
      <div className="w-[375px] h-[812px] bg-white rounded-[40px] shadow-2xl relative overflow-hidden flex flex-col border-[8px] border-white box-content ring-1 ring-gray-300/50">
        
        {/* Status Bar (Simulated) */}
        <div className="h-12 w-full flex justify-between items-center px-6 pt-2 absolute top-0 z-50 pointer-events-none">
            <span className="text-xs font-bold text-gray-800">9:41</span>
            <div className="flex gap-1">
                <div className="w-4 h-4 bg-gray-800 rounded-full opacity-20"></div>
                <div className="w-4 h-4 bg-gray-800 rounded-full opacity-60"></div>
            </div>
        </div>

        {/* Dynamic Content */}
        <div className="flex-1 overflow-y-auto no-scrollbar bg-brand-bg scroll-smooth relative">
           {activeTab === 'home' && <HomeView onOpenStall={setSelectedStallId} />}
           {activeTab === 'radar' && <RadarView />}
           {activeTab === 'community' && <CommunityView />}
           {activeTab === 'order' && <OrderView />}
           {activeTab === 'profile' && <ProfileView />}
        </div>

        {/* Detail Modal */}
        {selectedStallId && (
          <StallDetailModal stallId={selectedStallId} onClose={() => setSelectedStallId(null)} />
        )}

        {/* Navigation */}
        <NavBar activeTab={activeTab} onSwitch={setActiveTab} />
      </div>
    </div>
  );
};

export default App;
