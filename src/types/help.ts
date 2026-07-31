/**
 * Type definitions for the Smart Contextual Help System
 */

export type TipType = "tip" | "warning" | "info";

export interface HelpTip {
  text: string;
  type: TipType;
}

export interface HelpItem {
  id: string;
  title: string;
  description: string;
  example?: string | string[];
  tips?: HelpTip[];
  imageUrl?: string;
  icon?: string;
}

export type HelpDictionary = Record<string, HelpItem>;
