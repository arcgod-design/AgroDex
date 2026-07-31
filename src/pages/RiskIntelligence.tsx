import { useQuery } from "@tanstack/react-query";
import { Helmet } from "react-helmet-async";
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import {
  AlertTriangle,
  BrainCircuit,
  CheckCircle2,
  Clock3,
  Factory,
  LineChart,
  PackageCheck,
  RefreshCw,
  ShieldAlert,
  ShieldCheck,
  Sparkles,
  Truck,
} from "lucide-react";
import Footer from "@/components/Footer";
import Navbar from "@/components/Navbar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Skeleton } from "@/components/ui/skeleton";
import { ContextHelp } from "@/components/help";
import {
  getSupplyChainRiskAssessment,
  type HeatmapCell,
  type Recommendation,
  type RiskScoreCard,
  type SupplierReliability,
  type SupplyChainRiskLevel,
} from "@/lib/supplyChainRiskAi";

const levelStyles: Record<
  SupplyChainRiskLevel,
  { label: string; color: string; badge: string; cell: string }
> = {
  low: {
    label: "Low",
    color: "#059669",
    badge: "bg-emerald-100 text-emerald-700 dark:bg-emerald-950/50 dark:text-emerald-300",
    cell: "bg-emerald-500",
  },
  moderate: {
    label: "Moderate",
    color: "#d97706",
    badge: "bg-amber-100 text-amber-700 dark:bg-amber-950/50 dark:text-amber-300",
    cell: "bg-amber-500",
  },
  elevated: {
    label: "Elevated",
    color: "#dc2626",
    badge: "bg-red-100 text-red-700 dark:bg-red-950/50 dark:text-red-300",
    cell: "bg-red-500",
  },
  critical: {
    label: "Critical",
    color: "#7c3aed",
    badge: "bg-violet-100 text-violet-700 dark:bg-violet-950/50 dark:text-violet-300",
    cell: "bg-violet-500",
  },
};

const scoreIcons = {
  overall: BrainCircuit,
  delay: Clock3,
  fraud: ShieldAlert,
  inventory: PackageCheck,
  supplier: ShieldCheck,
} as const;

const priorityClass: Record<Recommendation["priority"], string> = {
  High: "border-red-200 bg-red-50 text-red-700 dark:border-red-900/50 dark:bg-red-950/20 dark:text-red-300",
  Medium:
    "border-amber-200 bg-amber-50 text-amber-700 dark:border-amber-900/50 dark:bg-amber-950/20 dark:text-amber-300",
  Low: "border-emerald-200 bg-emerald-50 text-emerald-700 dark:border-emerald-900/50 dark:bg-emerald-950/20 dark:text-emerald-300",
};

function getHeatLevel(risk: number): SupplyChainRiskLevel {
  if (risk >= 82) return "critical";
  if (risk >= 62) return "elevated";
  if (risk >= 40) return "moderate";
  return "low";
}

function RiskScoreCards({ cards }: { cards: RiskScoreCard[] }) {
  return (
    <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-5">
      {cards.map((card) => {
        const Icon = scoreIcons[card.id];
        const style = levelStyles[card.level];

        return (
          <Card key={card.id} className="bg-card">
            <CardHeader className="space-y-0 pb-3">
              <div className="flex items-start justify-between gap-3">
                <div>
                  <CardTitle className="text-sm font-semibold text-muted-foreground flex items-center gap-1.5">
                    {card.label}
                    {card.id === "fraud" && (
                      <ContextHelp helpId="risk.riskScore" size={12} side="right" />
                    )}
                  </CardTitle>
                  <div className="mt-2 flex items-end gap-2">
                    <span className="text-3xl font-extrabold text-foreground">{card.score}</span>
                    <span className="pb-1 text-xs font-semibold text-muted-foreground">/100</span>
                  </div>
                </div>
                <div className="rounded-lg bg-muted p-2">
                  <Icon className="h-5 w-5" style={{ color: style.color }} />
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-3">
              <Progress value={card.score} className="h-2" />
              <div className="flex items-center justify-between gap-2">
                <Badge className={style.badge}>{style.label}</Badge>
                <span className={card.change > 0 ? "text-xs font-semibold text-red-600" : "text-xs font-semibold text-emerald-600"}>
                  {card.change > 0 ? "+" : ""}
                  {card.change} pts
                </span>
              </div>
              <p className="text-xs leading-relaxed text-muted-foreground">{card.description}</p>
            </CardContent>
          </Card>
        );
      })}
    </div>
  );
}

function RiskHeatmap({ cells }: { cells: HeatmapCell[] }) {
  const regions = Array.from(new Set(cells.map((cell) => cell.region)));
  const stages = Array.from(new Set(cells.map((cell) => cell.stage)));

  return (
    <div className="overflow-x-auto">
      <div className="min-w-[640px] space-y-2">
        <div className="grid grid-cols-[100px_repeat(5,minmax(88px,1fr))] gap-2 text-xs font-semibold text-muted-foreground">
          <span>Region</span>
          {stages.map((stage) => (
            <span key={stage} className="text-center">{stage}</span>
          ))}
        </div>
        {regions.map((region) => (
          <div key={region} className="grid grid-cols-[100px_repeat(5,minmax(88px,1fr))] gap-2">
            <div className="flex items-center text-sm font-semibold text-foreground">{region}</div>
            {stages.map((stage) => {
              const cell = cells.find((item) => item.region === region && item.stage === stage);
              const risk = cell?.risk ?? 0;
              const level = getHeatLevel(risk);

              return (
                <div
                  key={`${region}-${stage}`}
                  className={`flex h-14 items-center justify-center rounded-md text-sm font-bold text-white shadow-sm ${levelStyles[level].cell}`}
                  style={{ opacity: 0.45 + risk / 180 }}
                  title={`${region} ${stage}: ${risk}/100`}
                >
                  {risk}
                </div>
              );
            })}
          </div>
        ))}
      </div>
    </div>
  );
}

function SupplierList({ suppliers }: { suppliers: SupplierReliability[] }) {
  return (
    <div className="space-y-3">
      {suppliers.map((supplier) => (
        <div key={supplier.supplier} className="rounded-lg border border-border bg-muted/20 p-3">
          <div className="flex items-start justify-between gap-3">
            <div>
              <p className="font-semibold text-foreground">{supplier.supplier}</p>
              <p className="text-xs text-muted-foreground">
                {supplier.incidents} incident{supplier.incidents === 1 ? "" : "s"} · {supplier.trend}
              </p>
            </div>
            <span className="text-lg font-extrabold text-foreground">{supplier.reliability}%</span>
          </div>
          <Progress value={supplier.reliability} className="mt-3 h-2" />
        </div>
      ))}
    </div>
  );
}

export default function RiskIntelligence() {
  const { data, isLoading, isError, error, refetch, isFetching } = useQuery({
    queryKey: ["supply-chain-risk-assessment"],
    queryFn: getSupplyChainRiskAssessment,
    refetchOnWindowFocus: false,
    staleTime: 5 * 60 * 1000,
  });

  return (
    <div className="min-h-screen bg-background text-foreground">
      <Helmet>
        <title>AI Supply Chain Risk Dashboard | AgroDex</title>
        <meta
          name="description"
          content="AI-powered supply chain risk assessment dashboard for AgroDex logistics, fraud, inventory, and supplier signals."
        />
      </Helmet>

      <Navbar />

      <section className="border-b border-border bg-gradient-to-br from-emerald-50 via-sky-50 to-white dark:from-emerald-950/20 dark:via-sky-950/10 dark:to-background">
        <div className="container mx-auto px-4 py-12 lg:py-16">
          <div className="flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
            <div className="max-w-3xl">
              <Badge className="mb-4 bg-emerald-100 text-emerald-700 dark:bg-emerald-950/50 dark:text-emerald-300">
                <Sparkles className="mr-2 h-4 w-4" />
                AI-powered risk assessment
              </Badge>
              <h1 className="text-4xl font-extrabold tracking-tight text-gray-900 dark:text-white sm:text-5xl">
                Supply Chain Risk Dashboard
              </h1>
              <p className="mt-4 text-base leading-7 text-muted-foreground sm:text-lg">
                Monitor delay exposure, fraud probability, inventory pressure, and supplier reliability across active AgroDex agricultural lanes.
              </p>
            </div>
            <Button
              onClick={() => refetch()}
              disabled={isFetching}
              className="w-full bg-emerald-600 text-white hover:bg-emerald-700 sm:w-auto"
            >
              <RefreshCw className={`mr-2 h-4 w-4 ${isFetching ? "animate-spin" : ""}`} />
              {isFetching ? "Refreshing" : "Refresh AI assessment"}
            </Button>
          </div>
        </div>
      </section>

      <main className="container mx-auto space-y-6 px-4 py-8">
        {isLoading && (
          <div className="space-y-6">
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-5">
              {Array.from({ length: 5 }).map((_, index) => (
                <Skeleton key={index} className="h-48 rounded-lg" />
              ))}
            </div>
            <Skeleton className="h-80 rounded-lg" />
          </div>
        )}

        {isError && !isLoading && (
          <Card className="border-red-200 bg-red-50 dark:border-red-900/40 dark:bg-red-950/20">
            <CardContent className="flex flex-col items-center gap-3 py-12 text-center">
              <AlertTriangle className="h-10 w-10 text-red-600" />
              <div>
                <h2 className="text-lg font-bold text-red-700 dark:text-red-300">Risk assessment failed</h2>
                <p className="mt-1 text-sm text-red-600 dark:text-red-300">
                  {error instanceof Error ? error.message : "Unable to load the AI risk assessment."}
                </p>
              </div>
              <Button onClick={() => refetch()} variant="outline">
                <RefreshCw className="mr-2 h-4 w-4" />
                Retry
              </Button>
            </CardContent>
          </Card>
        )}

        {data && !isLoading && (
          <>
            <RiskScoreCards cards={data.scoreCards} />

            <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
              <Card className="xl:col-span-2">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <BrainCircuit className="h-5 w-5 text-emerald-600" />
                    AI Risk Summary
                  </CardTitle>
                  <CardDescription>
                    Generated {new Date(data.generatedAt).toLocaleString()} · {data.confidence}% confidence
                  </CardDescription>
                </CardHeader>
                <CardContent>
                  <p className="text-sm leading-7 text-muted-foreground">{data.summary}</p>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <ShieldAlert className="h-5 w-5 text-amber-600" />
                    {data.fraudIndicator.label}
                  </CardTitle>
                  <CardDescription>Probability from document, QR, and anomaly signals</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-end justify-between gap-4">
                    <span className="text-4xl font-extrabold">{data.fraudIndicator.probability}%</span>
                    <Badge className={levelStyles[data.fraudIndicator.level].badge}>
                      {levelStyles[data.fraudIndicator.level].label}
                    </Badge>
                  </div>
                  <Progress value={data.fraudIndicator.probability} className="h-2" />
                  <div className="space-y-2">
                    {data.fraudIndicator.signals.map((signal) => (
                      <div key={signal} className="flex gap-2 text-sm text-muted-foreground">
                        <CheckCircle2 className="mt-0.5 h-4 w-4 shrink-0 text-emerald-600" />
                        <span>{signal}</span>
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </div>

            <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Truck className="h-5 w-5 text-sky-600" />
                    Delay Prediction
                  </CardTitle>
                  <CardDescription>AI-estimated ETA risk for active logistics lanes</CardDescription>
                </CardHeader>
                <CardContent className="space-y-4">
                  {data.delayPredictions.map((prediction) => (
                    <div key={prediction.lane} className="rounded-lg border border-border p-4">
                      <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
                        <div>
                          <p className="font-semibold">{prediction.lane}</p>
                          <p className="text-xs text-muted-foreground">ETA {prediction.eta}</p>
                        </div>
                        <Badge className={levelStyles[getHeatLevel(prediction.delayProbability)].badge}>
                          {prediction.delayProbability}% delay
                        </Badge>
                      </div>
                      <Progress value={prediction.delayProbability} className="mt-3 h-2" />
                      <p className="mt-3 text-sm text-muted-foreground">
                        {prediction.predictedDelayHours}h predicted delay · {prediction.driver}
                      </p>
                    </div>
                  ))}
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <LineChart className="h-5 w-5 text-violet-600" />
                    Risk Trend
                  </CardTitle>
                  <CardDescription>Recent movement across major risk categories</CardDescription>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width="100%" height={300}>
                    <AreaChart data={data.trends} margin={{ top: 8, right: 12, left: -20, bottom: 0 }}>
                      <CartesianGrid strokeDasharray="3 3" stroke="rgba(148,163,184,0.25)" />
                      <XAxis dataKey="date" tick={{ fontSize: 12 }} />
                      <YAxis tick={{ fontSize: 12 }} />
                      <Tooltip
                        contentStyle={{
                          background: "hsl(var(--popover))",
                          border: "1px solid hsl(var(--border))",
                          borderRadius: "8px",
                        }}
                      />
                      <Area type="monotone" dataKey="overallRisk" name="Overall" stroke="#059669" fill="#059669" fillOpacity={0.14} strokeWidth={2} />
                      <Area type="monotone" dataKey="delayRisk" name="Delay" stroke="#0284c7" fill="#0284c7" fillOpacity={0.1} strokeWidth={2} />
                      <Area type="monotone" dataKey="fraudRisk" name="Fraud" stroke="#d97706" fill="#d97706" fillOpacity={0.08} strokeWidth={2} />
                    </AreaChart>
                  </ResponsiveContainer>
                </CardContent>
              </Card>
            </div>

            <div className="grid grid-cols-1 gap-6 xl:grid-cols-3">
              <Card className="xl:col-span-2">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Factory className="h-5 w-5 text-red-600" />
                    Visual Risk Heatmap
                  </CardTitle>
                  <CardDescription>Risk intensity by region and supply-chain stage</CardDescription>
                </CardHeader>
                <CardContent>
                  <RiskHeatmap cells={data.heatmap} />
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>AI Recommendations</CardTitle>
                  <CardDescription>Prioritized interventions from the mock AI engine</CardDescription>
                </CardHeader>
                <CardContent className="space-y-3">
                  {data.recommendations.map((recommendation) => (
                    <div key={recommendation.id} className="rounded-lg border border-border p-4">
                      <Badge variant="outline" className={priorityClass[recommendation.priority]}>
                        {recommendation.priority}
                      </Badge>
                      <h3 className="mt-3 font-semibold">{recommendation.title}</h3>
                      <p className="mt-2 text-sm text-muted-foreground">{recommendation.action}</p>
                      <p className="mt-2 text-xs font-semibold text-emerald-600">{recommendation.impact}</p>
                    </div>
                  ))}
                </CardContent>
              </Card>
            </div>

            <div className="grid grid-cols-1 gap-6 xl:grid-cols-2">
              <Card>
                <CardHeader>
                  <CardTitle>Inventory Risk Signals</CardTitle>
                  <CardDescription>Coverage and replenishment pressure for verified lots</CardDescription>
                </CardHeader>
                <CardContent>
                  <ResponsiveContainer width="100%" height={260}>
                    <BarChart data={data.inventorySignals} margin={{ top: 8, right: 12, left: -20, bottom: 40 }}>
                      <CartesianGrid strokeDasharray="3 3" stroke="rgba(148,163,184,0.25)" />
                      <XAxis dataKey="sku" angle={-18} textAnchor="end" interval={0} tick={{ fontSize: 11 }} />
                      <YAxis tick={{ fontSize: 12 }} />
                      <Tooltip
                        contentStyle={{
                          background: "hsl(var(--popover))",
                          border: "1px solid hsl(var(--border))",
                          borderRadius: "8px",
                        }}
                      />
                      <Bar dataKey="coverageDays" name="Coverage days" radius={[6, 6, 0, 0]}>
                        {data.inventorySignals.map((signal) => (
                          <Cell key={signal.sku} fill={levelStyles[signal.reorderUrgency].color} />
                        ))}
                      </Bar>
                    </BarChart>
                  </ResponsiveContainer>
                </CardContent>
              </Card>

              <Card>
                <CardHeader>
                  <CardTitle>Supplier Reliability</CardTitle>
                  <CardDescription>Reliability index and incident trend by partner</CardDescription>
                </CardHeader>
                <CardContent>
                  <SupplierList suppliers={data.suppliers} />
                </CardContent>
              </Card>
            </div>
          </>
        )}
      </main>

      <Footer />
    </div>
  );
}
