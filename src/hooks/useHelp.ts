import { useState, useCallback, useEffect } from "react";
import { HELP } from "@/data/helpContent";
import type { HelpItem } from "@/types/help";

export interface UseHelpReturn {
  activeHelp: HelpItem | null;
  openHelp: (id: string) => void;
  closeHelp: () => void;
  isOpen: boolean;
  searchResults: HelpItem[];
  searchQuery: string;
  setSearchQuery: (q: string) => void;
  isCommandPaletteOpen: boolean;
  openCommandPalette: () => void;
  closeCommandPalette: () => void;
}

export function useHelp(): UseHelpReturn {
  const [activeHelp, setActiveHelp] = useState<HelpItem | null>(null);
  const [isCommandPaletteOpen, setIsCommandPaletteOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

  const openHelp = useCallback((id: string) => {
    const item = HELP[id] ?? null;
    setActiveHelp(item);
  }, []);

  const closeHelp = useCallback(() => {
    setActiveHelp(null);
  }, []);

  const openCommandPalette = useCallback(() => {
    setIsCommandPaletteOpen(true);
  }, []);

  const closeCommandPalette = useCallback(() => {
    setIsCommandPaletteOpen(false);
    setSearchQuery("");
  }, []);

  // Global keyboard shortcut: Ctrl+/ or ?
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Ctrl+/ or Ctrl+Shift+/
      if ((e.ctrlKey && e.key === "/") || (e.key === "?" && !e.ctrlKey && !e.metaKey)) {
        const tag = (e.target as HTMLElement).tagName;
        // Don't intercept if user is typing in an input
        if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") return;
        e.preventDefault();
        setIsCommandPaletteOpen((prev) => !prev);
      }
      if (e.key === "Escape") {
        setIsCommandPaletteOpen(false);
        setActiveHelp(null);
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  // Search across all help items
  const searchResults: HelpItem[] = searchQuery.trim()
    ? Object.values(HELP).filter((item) => {
        const q = searchQuery.toLowerCase();
        return (
          item.title.toLowerCase().includes(q) ||
          item.description.toLowerCase().includes(q) ||
          (Array.isArray(item.example)
            ? item.example.some((ex) => ex.toLowerCase().includes(q))
            : item.example?.toLowerCase().includes(q))
        );
      })
    : Object.values(HELP);

  return {
    activeHelp,
    openHelp,
    closeHelp,
    isOpen: activeHelp !== null,
    searchResults,
    searchQuery,
    setSearchQuery,
    isCommandPaletteOpen,
    openCommandPalette,
    closeCommandPalette,
  };
}
