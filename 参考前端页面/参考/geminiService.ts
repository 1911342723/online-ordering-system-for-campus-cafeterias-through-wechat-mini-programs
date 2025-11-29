import { GoogleGenAI } from "@google/genai";

// Initialize Gemini Client
// In a real scenario, never expose keys in client-side code if not using a proxy.
// However, per instructions, we use process.env.API_KEY.
const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });

export const getFoodRecommendation = async (mood: string, availableStalls: string): Promise<string> => {
  try {
    const prompt = `
      You are a playful, youthful food guide assistant for college students.
      The user feels: "${mood}".
      Available stalls: ${availableStalls}.
      
      Task:
      1. Pick ONE stall from the list that fits the user's mood.
      2. Provide a short, witty reason (max 1 sentence).
      3. Use emojis.
      4. Output plain text.
    `;
    
    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: prompt,
    });

    return response.text || "Connection lost to the food spirits... try again!";
  } catch (error) {
    console.error("Gemini API Error:", error);
    return "AI is taking a nap. Pick whatever smells good!";
  }
};

export const summarizeReviews = async (reviewsJson: string): Promise<string> => {
  try {
    const prompt = `
      Summarize these reviews for a food stall into 3 extremely concise bullet points (Pros & Cons).
      Reviews: ${reviewsJson}.
      
      Format:
      ✅ [Pro]
      ⚠️ [Con]
      💡 [Tip]
    `;

    const response = await ai.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: prompt,
    });

    return response.text || "Could not summarize reviews.";
  } catch (error) {
    console.error("Gemini API Error:", error);
    return "Failed to analyze reviews.";
  }
};
