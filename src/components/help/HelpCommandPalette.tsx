import * as React from "react";
import { useHelp } from "@/hooks/useHelp";
import { HELP } from "@/data/helpContent";
import type { HelpItem } from "@/types/help";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import {
  HelpCircle,
  CheckCircle2,
  AlertTriangle,
  Info,
  X,
} from "lucide-react";
import { AnimatePresence, motion } from "framer-motion";
import { cn } from "@/lib/utils";

// ─── Section labels from key prefixes ────────────────────────────────────────
const SECTION_LABELS: Record<string, string> = {
  auth: "Authentication",
  registration: "Batch Registration",
  dashboard: "Dashboard",
  risk: "Risk Intelligence",
  verify: "Batch Verification",
  tokenize: "Batch Tokenization",
  profile: "Profile & Settings",
};

function getSection(id: string): string {
  const prefix = id.split(".")[0];
  return SECTION_LABELS[prefix] ?? "General";
}

function groupBySection(items: HelpItem[]): Record<string, HelpItem[]> {
  return items.reduce<Record<string, HelpItem[]>>((acc, item) => {
    const section = getSection(item.id);
    if (!acc[section]) acc[section] = [];
    acc[section].push(item);
    return acc;
  }, {});
}

// ─── Detail Panel ─────────────────────────────────────────────────────────────
function HelpDetailPanel({ item }: { item: HelpItem }) {
  const examples = Array.isArray(item.example)
    ? item.example
    : item.example
    ? [item.example]
    : [];

  return (
    <motion.div
      key={item.id}
      initial={{ opacity: 0, x: 10 }}
      animate={{ opacity: 1, x: 0 }}
      exit={{ opacity: 0, x: 10 }}
      transition={{ duration: 0.2, ease: "easeOut" }}
      className="flex flex-col gap-3 p-4 h-full overflow-y-auto"
    >
      <div className="flex items-start gap-2">
        <HelpCircle className="h-5 w-5 text-emerald-500 shrink-0 mt-0.5" />
        <h3 className="text-sm font-semibold text-foreground">{item.title}</h3>
      </div>

      <p className="text-xs text-muted-foreground leading-relaxed">{item.description}</p>

      {examples.length > 0 && (
        <div className="space-y-1.5">
          <p className="text-xs font-medium text-foreground">Examples:</p>
          <div className="flex flex-wrap gap-1.5">
            {examples.map((ex) => (
              <Badge
                key={ex}
                variant="secondary"
                className="text-xs font-mono bg-emerald-50 dark:bg-emerald-950/40 text-emerald-700 dark:text-emerald-300 border border-emerald-200 dark:border-emerald-800"
              >
                {ex}
              </Badge>
            ))}
          </div>
        </div>
      )}

      {item.tips && item.tips.length > 0 && (
        <div className="space-y-2 border-t border-border pt-3">
          <p className="text-xs font-medium text-foreground">Tips &amp; Warnings:</p>
          {item.tips.map((tip, i) => (
            <div key={i} className="flex items-start gap-1.5">
              {tip.type === "tip" && (
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-500 shrink-0 mt-0.5" />
              )}
              {tip.type === "warning" && (
                <AlertTriangle className="h-3.5 w-3.5 text-amber-500 shrink-0 mt-0.5" />
              )}
              {tip.type === "info" && (
                <Info className="h-3.5 w-3.5 text-blue-500 shrink-0 mt-0.5" />
              )}
              <p
                className={cn(
                  "text-xs leading-relaxed",
                  tip.type === "tip" && "text-emerald-700 dark:text-emerald-400",
                  tip.type === "warning" && "text-amber-700 dark:text-amber-400",
                  tip.type === "info" && "text-blue-700 dark:text-blue-400"
                )}
              >
                {tip.text}
              </p>
            </div>
          ))}
        </div>
      )}
    </motion.div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────
export function HelpCommandPalette() {
  const { isCommandPaletteOpen, closeCommandPalette } = useHelp();

  // ── Local state ──────────────────────────────────────────────────────────
  // We own the search query locally so cmdk can do its own internal filtering.
  // (Previously, shouldFilter={false} + external query broke cmdk's onSelect.)
  const [query, setQuery] = React.useState("");
  const [selected, setSelected] = React.useState<HelpItem | null>(null);

  // All items — cmdk's built-in filter will handle search matching via value=""
  const allItems = React.useMemo(() => Object.values(HELP), []);

  // When the palette opens, pre-select the first item.
  React.useEffect(() => {
    if (isCommandPaletteOpen) {
      setQuery("");
      setSelected(allItems[0] ?? null);
    }
  }, [isCommandPaletteOpen, allItems]);

  // Group the full item list; cmdk handles showing/hiding based on its filter.
  // We group ALL items (not filtered), because cmdk manages visibility itself.
  const grouped = React.useMemo(() => groupBySection(allItems), [allItems]);

  // ── Selection handler ────────────────────────────────────────────────────
  // Called by both mouse click and keyboard Enter via cmdk's onSelect.
  const handleSelect = React.useCallback((item: HelpItem) => {
    setSelected(item);
  }, []);

  return (
    <Dialog
      open={isCommandPaletteOpen}
      onOpenChange={(open) => {
        if (!open) closeCommandPalette();
      }}
    >
      <DialogContent
        className="max-w-3xl w-[calc(100vw-2rem)] p-0 gap-0 overflow-hidden shadow-2xl border border-border"
        aria-label="Help Search"
        // Prevent Dialog's default close-on-Escape from conflicting with cmdk
        onEscapeKeyDown={(e) => {
          e.preventDefault();
          closeCommandPalette();
        }}
      >
        <DialogHeader className="sr-only">
          <DialogTitle>Help Search</DialogTitle>
        </DialogHeader>

        {/* Close button */}
        <button
          type="button"
          onClick={closeCommandPalette}
          aria-label="Close help search"
          className="absolute top-3 right-3 z-10 text-muted-foreground hover:text-foreground transition-colors rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-emerald-500"
        >
          <X className="h-4 w-4" />
        </button>

        {/*
          Content-driven layout: the outer div has no fixed height.
          max-h-[80vh] prevents it from growing taller than the viewport.
          Each panel scrolls independently only when its content exceeds
          the available space — no blank space reserved for missing items.
        */}
        <div className="flex min-h-0 max-h-[80vh]">
          {/* ── Left panel: Search + Results ─────────────────────────────── */}
          <div className="flex flex-col w-1/2 border-r border-border min-w-0 min-h-0">
            <Command className="rounded-none border-0 shadow-none flex flex-col min-h-0">
              <CommandInput
                placeholder="Search help topics…"
                value={query}
                onValueChange={setQuery}
                autoFocus
                className="h-12 text-sm shrink-0"
                aria-label="Search help topics"
              />

              <CommandList className="overflow-y-auto" style={{ maxHeight: 'min(calc(80vh - 3rem - 2.5rem), 600px)' }}>
                <CommandEmpty className="py-6 text-center text-sm text-muted-foreground">
                  No results found.
                </CommandEmpty>

                {Object.entries(grouped).map(([section, items]) => (
                  <CommandGroup key={section} heading={section}>
                    {items.map((item) => (
                      <CommandItem
                        key={item.id}
                        // `value` is what cmdk matches against the search query.
                        // Using "title description" gives richer matching.
                        value={`${item.title} ${item.description}`}
                        // onSelect is called by cmdk for BOTH mouse click AND
                        // keyboard Enter. This was the missing piece.
                        onSelect={() => handleSelect(item)}
                        className={cn(
                          "cursor-pointer text-xs py-2 gap-2",
                          selected?.id === item.id &&
                            "bg-emerald-50 dark:bg-emerald-950/30 text-emerald-700 dark:text-emerald-300"
                        )}
                        aria-selected={selected?.id === item.id}
                      >
                        <HelpCircle className="h-3.5 w-3.5 text-muted-foreground shrink-0" />
                        <span className="truncate">{item.title}</span>
                      </CommandItem>
                    ))}
                  </CommandGroup>
                ))}
              </CommandList>
            </Command>
          </div>

          {/* ── Right panel: Detail view ─────────────────────────────────── */}
          <div className="w-1/2 overflow-y-auto max-h-[80vh]">
            <AnimatePresence mode="wait">
              {selected ? (
                <HelpDetailPanel key={selected.id} item={selected} />
              ) : (
                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="flex flex-col items-center justify-center h-full gap-3 text-center p-6"
                >
                  <HelpCircle className="h-10 w-10 text-muted-foreground/40" />
                  <p className="text-sm text-muted-foreground">
                    Select a topic to view details
                  </p>
                  <p className="text-xs text-muted-foreground/60">
                    Press{" "}
                    <kbd className="px-1.5 py-0.5 rounded border border-border text-xs font-mono">
                      Ctrl + /
                    </kbd>{" "}
                    to toggle
                  </p>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </div>

        {/* ── Footer ───────────────────────────────────────────────────────── */}
        <div className="border-t border-border px-4 py-2 flex items-center gap-4 text-xs text-muted-foreground bg-muted/30">
          <span>
            <kbd className="px-1.5 py-0.5 rounded border border-border font-mono">↑↓</kbd>{" "}
            Navigate
          </span>
          <span>
            <kbd className="px-1.5 py-0.5 rounded border border-border font-mono">Enter</kbd>{" "}
            Select
          </span>
          <span>
            <kbd className="px-1.5 py-0.5 rounded border border-border font-mono">Esc</kbd>{" "}
            Close
          </span>
          <span className="ml-auto hidden sm:inline">
            Press{" "}
            <kbd className="px-1.5 py-0.5 rounded border border-border font-mono">Ctrl+/</kbd>{" "}
            anytime to open
          </span>
        </div>
      </DialogContent>
    </Dialog>
  );
}
