import * as React from "react";
import { useHelp } from "@/hooks/useHelp";
import type { UseHelpReturn } from "@/hooks/useHelp";

// Re-export the type for consumers
export type { UseHelpReturn };

const HelpContext = React.createContext<ReturnType<typeof useHelp> | null>(null);

export function HelpProvider({ children }: { children: React.ReactNode }) {
  const helpState = useHelp();
  return <HelpContext.Provider value={helpState}>{children}</HelpContext.Provider>;
}

/** Access global help state from any component */
export function useHelpContext() {
  const ctx = React.useContext(HelpContext);
  if (!ctx) {
    throw new Error("useHelpContext must be used inside <HelpProvider>");
  }
  return ctx;
}
