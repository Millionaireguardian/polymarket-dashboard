/**
 * Professional Polymarket Arbitrage Bot Dashboard
 * Real-time trade tracking and P&L visualization
 */

// Dashboard Configuration
const CONFIG = {
    tradesFile: './data/trades.json',
    updateInterval: 30000, // 30 seconds
};

// Global state
let balanceChart = null;
let winRateChart = null;
let tradesData = [];
let filteredTrades = [];
let sortColumn = 'timestamp';
let sortDirection = 'desc';
let searchQuery = '';

// Initialize dashboard
document.addEventListener('DOMContentLoaded', () => {
    initializeCharts();
    setupEventListeners();
    loadTrades();
    setInterval(loadTrades, CONFIG.updateInterval);
});

// Setup event listeners
function setupEventListeners() {
    // Search input
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            searchQuery = e.target.value.toLowerCase();
            filterAndRenderTrades();
        });
    }

    // Clear search button
    const clearSearch = document.getElementById('clearSearch');
    if (clearSearch) {
        clearSearch.addEventListener('click', () => {
            searchInput.value = '';
            searchQuery = '';
            filterAndRenderTrades();
        });
    }

    // Sortable table headers
    document.querySelectorAll('.sortable').forEach(header => {
        header.addEventListener('click', () => {
            const column = header.dataset.sort;
            if (sortColumn === column) {
                sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
            } else {
                sortColumn = column;
                sortDirection = 'desc';
            }
            updateSortIndicators();
            filterAndRenderTrades();
        });
    });

    // Chart period buttons
    document.querySelectorAll('.chart-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            document.querySelectorAll('.chart-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            const period = btn.dataset.period;
            updateChart(period);
        });
    });
}

// Update sort indicators
function updateSortIndicators() {
    document.querySelectorAll('.sortable').forEach(header => {
        header.classList.remove('sort-asc', 'sort-desc');
        if (header.dataset.sort === sortColumn) {
            header.classList.add(sortDirection === 'asc' ? 'sort-asc' : 'sort-desc');
        }
    });
}

// Initialize Chart.js charts
function initializeCharts() {
    // Balance over time chart
    const balanceCtx = document.getElementById('balanceChart');
    if (balanceCtx) {
        balanceChart = new Chart(balanceCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Balance',
                    data: [],
                    borderColor: '#10b981',
                    backgroundColor: 'rgba(16, 185, 129, 0.1)',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 0,
                    pointHoverRadius: 6,
                    pointHoverBackgroundColor: '#10b981',
                    pointHoverBorderColor: '#ffffff',
                    pointHoverBorderWidth: 2,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false,
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false,
                        backgroundColor: '#1a1a1a',
                        titleColor: '#ffffff',
                        bodyColor: '#e0e0e0',
                        borderColor: '#2a2a2a',
                        borderWidth: 1,
                        padding: 12,
                        displayColors: false,
                        callbacks: {
                            label: function(context) {
                                return 'Balance: $' + context.parsed.y.toFixed(2);
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        ticks: {
                            color: '#a0a0a0',
                            font: {
                                size: 11
                            }
                        },
                        grid: {
                            color: '#2a2a2a',
                            drawBorder: false,
                        }
                    },
                    y: {
                        ticks: {
                            color: '#a0a0a0',
                            font: {
                                size: 11
                            },
                            callback: function(value) {
                                return '$' + value.toFixed(2);
                            }
                        },
                        grid: {
                            color: '#2a2a2a',
                            drawBorder: false,
                        }
                    }
                },
                interaction: {
                    intersect: false,
                    mode: 'index',
                }
            }
        });
    }

    // Win rate pie chart
    const winRateCtx = document.getElementById('winRateChart');
    if (winRateCtx) {
        winRateChart = new Chart(winRateCtx, {
            type: 'doughnut',
            data: {
                labels: ['Wins', 'Losses'],
                datasets: [{
                    data: [0, 0],
                    backgroundColor: ['#10b981', '#ef4444'],
                    borderWidth: 0,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false,
                    },
                    tooltip: {
                        backgroundColor: '#1a1a1a',
                        titleColor: '#ffffff',
                        bodyColor: '#e0e0e0',
                        borderColor: '#2a2a2a',
                        borderWidth: 1,
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.parsed || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0;
                                return label + ': ' + value + ' (' + percentage + '%)';
                            }
                        }
                    }
                },
                cutout: '70%',
            }
        });
    }
}

// Load trades from JSON file
async function loadTrades() {
    showLoading(true);
    
    try {
        // Add cache-busting timestamp to prevent browser caching
        const cacheBuster = '?t=' + Date.now() + '&v=' + Math.random();
        const response = await fetch(CONFIG.tradesFile + cacheBuster, {
            cache: 'no-store',
            headers: {
                'Cache-Control': 'no-cache',
                'Pragma': 'no-cache'
            }
        });
        
        if (!response.ok) {
            throw new Error(`Failed to load trades: ${response.status} ${response.statusText}`);
        }
        
        const data = await response.json();
        tradesData = Array.isArray(data) ? data : [];
        
        // Log for debugging
        if (tradesData.length > 0) {
            const lastTrade = tradesData[tradesData.length - 1];
            console.log(`✅ Loaded ${tradesData.length} trades. Last trade: ${lastTrade.timestamp}`);
        } else {
            console.log('ℹ️  No trades found in data file');
        }
        
        updateStatus(true);
        
        // Handle empty trades gracefully
        if (tradesData.length === 0) {
            renderEmptyState();
        } else {
            renderDashboard();
        }
        
        showLoading(false);
    } catch (error) {
        console.error('❌ Error loading trades:', error);
        updateStatus(false);
        showError('Failed to load trades. Make sure the bot is running and trades.json exists.');
        showLoading(false);
    }
}

// Show/hide loading spinner
function showLoading(show) {
    const spinner = document.getElementById('loadingSpinner');
    if (spinner) {
        if (show) {
            spinner.classList.add('active');
        } else {
            spinner.classList.remove('active');
        }
    }
}

// Update connection status
function updateStatus(online) {
    const indicator = document.getElementById('statusIndicator');
    const lastUpdate = document.getElementById('lastUpdate');
    
    // Check if bot is actively running (has recent trades within last 5 minutes)
    const isBotActive = checkBotActive();
    
    if (indicator) {
        if (isBotActive) {
            indicator.className = 'status-indicator active';
            indicator.title = 'Bot is actively running';
        } else if (online) {
            indicator.className = 'status-indicator';
            indicator.title = 'Dashboard online (bot may be offline)';
        } else {
            indicator.className = 'status-indicator offline';
            indicator.title = 'Dashboard offline';
        }
    }
    
    if (lastUpdate) {
        if (isBotActive) {
            const lastTrade = getLastTradeTime();
            const minutesAgo = lastTrade ? Math.floor((Date.now() - new Date(lastTrade).getTime()) / 60000) : 0;
            lastUpdate.textContent = `Bot active - Last trade: ${minutesAgo}m ago (refreshes every 30s)`;
        } else if (online) {
            lastUpdate.textContent = `Dashboard online - Bot appears offline (refreshes every 30s)`;
        } else {
            lastUpdate.textContent = 'Offline - Cannot load data';
        }
    }
}

// Check if bot is actively running (has trades within last 5 minutes)
function checkBotActive() {
    if (tradesData.length === 0) return false;
    
    const lastTrade = tradesData[tradesData.length - 1];
    if (!lastTrade || !lastTrade.timestamp) return false;
    
    const lastTradeTime = new Date(lastTrade.timestamp).getTime();
    const fiveMinutesAgo = Date.now() - (5 * 60 * 1000);
    
    return lastTradeTime > fiveMinutesAgo;
}

// Get timestamp of last trade
function getLastTradeTime() {
    if (tradesData.length === 0) return null;
    const lastTrade = tradesData[tradesData.length - 1];
    return lastTrade ? lastTrade.timestamp : null;
}

// Render dashboard with current data
function renderDashboard() {
    if (tradesData.length === 0) {
        renderEmptyState();
        return;
    }

    calculateSummary();
    filterAndRenderTrades();
    updateChart('all');
    updateWinRateChart();
}

// Calculate summary statistics
function calculateSummary() {
    const trades = tradesData;
    
    if (trades.length === 0) {
        updateSummaryCards(0, 0, 0, 0, 0, 0, '-', 0, 0, 0);
        return;
    }

    // Sort trades by timestamp to ensure correct order
    const sortedTrades = [...trades].sort((a, b) => 
        new Date(a.timestamp) - new Date(b.timestamp)
    );

    // Get initial balance from first trade (if available) or default to 50
    const firstTrade = sortedTrades[0];
    const initialBalance = parseFloat(firstTrade?.initialBalance) || 
                          (firstTrade && parseFloat(firstTrade.balance) > 0 ? 
                           parseFloat(firstTrade.balance) + parseFloat(firstTrade.amount || 0) : 50);
    
    // Calculate current balance by working forward from initial balance
    let currentBalance = initialBalance;
    for (const trade of sortedTrades) {
        const amount = parseFloat(trade.amount || 0);
        if (trade.action === 'BUY') {
            currentBalance -= amount;
        } else if (trade.action === 'SELL') {
            currentBalance += amount;
        }
        
        // If trade has a logged balance, use it (but only if it's reasonable)
        const loggedBalance = parseFloat(trade.balance);
        if (loggedBalance > 0 && Math.abs(loggedBalance - currentBalance) < 100) {
            // Use logged balance if it's close to calculated (within $100)
            currentBalance = loggedBalance;
        }
    }
    
    // Use the last trade's balance if it's valid and positive
    const lastTrade = sortedTrades[sortedTrades.length - 1];
    if (lastTrade) {
        const lastBalance = parseFloat(lastTrade.balance);
        if (lastBalance > 0) {
            currentBalance = lastBalance;
        }
    }
    
    const balanceChange = currentBalance - initialBalance;
    const balanceChangePercent = initialBalance > 0 ? (balanceChange / initialBalance) * 100 : 0;
    
    // Total P&L: Sum of all P&L values, or calculate from balance change if all P&L is 0
    let totalPnL = trades.reduce((sum, trade) => {
        const pnl = parseFloat(trade.pnl) || 0;
        return sum + pnl;
    }, 0);
    
    // If all P&L is 0 (dry-run), use balance change as P&L
    if (totalPnL === 0 && trades.length > 0) {
        totalPnL = balanceChange;
    }
    
    const totalPnLPercent = estimatedInitial > 0 ? (totalPnL / estimatedInitial) * 100 : 0;
    
    // Daily P&L (trades from today)
    const today = new Date().toISOString().split('T')[0];
    const dailyTrades = trades.filter(t => t.timestamp.startsWith(today));
    const dailyPnL = dailyTrades.reduce((sum, trade) => sum + (trade.pnl || 0), 0);
    
    // Win rate
    const profitableTrades = trades.filter(t => (t.pnl || 0) > 0).length;
    const losingTrades = trades.filter(t => (t.pnl || 0) < 0).length;
    const winRate = trades.length > 0 ? (profitableTrades / trades.length) * 100 : 0;
    
    // Most traded market
    const marketCounts = {};
    trades.forEach(t => {
        const market = t.market || 'Unknown';
        marketCounts[market] = (marketCounts[market] || 0) + 1;
    });
    const mostTraded = Object.keys(marketCounts).length > 0
        ? Object.entries(marketCounts).sort((a, b) => b[1] - a[1])[0]
        : ['-', 0];
    
    updateSummaryCards(
        currentBalance,
        balanceChange,
        balanceChangePercent,
        totalPnL,
        totalPnLPercent,
        winRate,
        mostTraded[0],
        mostTraded[1],
        profitableTrades,
        losingTrades
    );
}

// Update summary cards
function updateSummaryCards(balance, balanceChange, balanceChangePercent, totalPnL, totalPnLPercent, winRate, mostTraded, mostTradedCount, wins, losses) {
    // Current Balance
    const balanceEl = document.getElementById('currentBalance');
    const balanceArrow = document.getElementById('balanceArrow');
    const balanceChangeEl = document.getElementById('balanceChange');
    
    if (balanceEl) {
        balanceEl.textContent = formatCurrency(balance);
        balanceEl.className = 'card-value ' + (balanceChange >= 0 ? 'positive' : 'negative');
    }
    
    if (balanceArrow) {
        balanceArrow.className = 'balance-arrow ' + (balanceChange >= 0 ? 'up' : 'down');
        balanceArrow.textContent = balanceChange >= 0 ? '↑' : '↓';
    }
    
    if (balanceChangeEl) {
        const sign = balanceChange >= 0 ? '+' : '';
        balanceChangeEl.textContent = `${sign}${formatCurrency(balanceChange)} (${sign}${balanceChangePercent.toFixed(2)}%)`;
        balanceChangeEl.className = 'card-change ' + (balanceChange >= 0 ? 'positive' : 'negative');
    }
    
    // Total P&L
    const totalPnLEl = document.getElementById('totalPnL');
    const totalPnLPercentEl = document.getElementById('totalPnLPercent');
    
    if (totalPnLEl) {
        totalPnLEl.textContent = formatCurrency(totalPnL);
        totalPnLEl.className = 'card-value ' + (totalPnL >= 0 ? 'positive' : 'negative');
    }
    
    if (totalPnLPercentEl) {
        const sign = totalPnLPercent >= 0 ? '+' : '';
        totalPnLPercentEl.textContent = `${sign}${totalPnLPercent.toFixed(2)}%`;
        totalPnLPercentEl.className = 'card-change ' + (totalPnLPercent >= 0 ? 'positive' : 'negative');
    }
    
    // Win Rate
    const winRateEl = document.getElementById('winRate');
    const winRateStatsEl = document.getElementById('winRateStats');
    
    if (winRateEl) {
        winRateEl.textContent = winRate.toFixed(1) + '%';
    }
    
    if (winRateStatsEl) {
        winRateStatsEl.textContent = `${wins}W / ${losses}L`;
    }
    
    // Most Traded Market
    const mostTradedEl = document.getElementById('mostTraded');
    const mostTradedCountEl = document.getElementById('mostTradedCount');
    
    if (mostTradedEl) {
        const displayName = mostTraded.length > 35 ? mostTraded.substring(0, 35) + '...' : mostTraded;
        mostTradedEl.textContent = displayName;
    }
    
    if (mostTradedCountEl) {
        mostTradedCountEl.textContent = `${mostTradedCount} trade${mostTradedCount !== 1 ? 's' : ''}`;
    }
}

// Update win rate pie chart
function updateWinRateChart() {
    if (!winRateChart) return;
    
    const trades = tradesData;
    const wins = trades.filter(t => (t.pnl || 0) > 0).length;
    const losses = trades.filter(t => (t.pnl || 0) < 0).length;
    
    winRateChart.data.datasets[0].data = [wins, losses];
    winRateChart.update('none');
}

// Filter and render trades table
function filterAndRenderTrades() {
    // Filter by search query
    filteredTrades = tradesData.filter(trade => {
        if (!searchQuery) return true;
        const market = (trade.market || '').toLowerCase();
        return market.includes(searchQuery);
    });
    
    // Sort trades
    filteredTrades.sort((a, b) => {
        let aVal, bVal;
        
        switch (sortColumn) {
            case 'timestamp':
                aVal = new Date(a.timestamp);
                bVal = new Date(b.timestamp);
                break;
            case 'market':
                aVal = (a.market || '').toLowerCase();
                bVal = (b.market || '').toLowerCase();
                break;
            case 'action':
                aVal = a.action || '';
                bVal = b.action || '';
                break;
            case 'price':
                aVal = parseFloat(a.price || 0);
                bVal = parseFloat(b.price || 0);
                break;
            case 'amount':
                aVal = parseFloat(a.amount || 0);
                bVal = parseFloat(b.amount || 0);
                break;
            case 'pnl':
                aVal = parseFloat(a.pnl || 0);
                bVal = parseFloat(b.pnl || 0);
                break;
            case 'balance':
                aVal = parseFloat(a.balance || 0);
                bVal = parseFloat(b.balance || 0);
                break;
            default:
                return 0;
        }
        
        if (aVal < bVal) return sortDirection === 'asc' ? -1 : 1;
        if (aVal > bVal) return sortDirection === 'asc' ? 1 : -1;
        return 0;
    });
    
    renderTradesTable();
}

// Render trades table
function renderTradesTable() {
    const tbody = document.getElementById('tradesBody');
    if (!tbody) return;
    
    if (filteredTrades.length === 0) {
        let message;
        if (searchQuery) {
            message = `No trades found matching "${searchQuery}"`;
        } else if (tradesData.length === 0) {
            message = `
                <div style="text-align: center; padding: 40px;">
                    <div style="font-size: 48px; margin-bottom: 20px;">📊</div>
                    <div style="font-size: 18px; font-weight: 600; color: var(--text-primary); margin-bottom: 10px;">
                        No trades yet
                    </div>
                    <div style="font-size: 14px; color: var(--text-secondary); max-width: 400px; margin: 0 auto; line-height: 1.6;">
                        Bot is running in dry-run mode. Trades will appear here once the bot detects arbitrage opportunities.
                    </div>
                </div>
            `;
        } else {
            message = 'No trades found matching your search.';
        }
        tbody.innerHTML = `<tr><td colspan="7" class="empty">${message}</td></tr>`;
        return;
    }
    
    // Sort filtered trades by timestamp for proper balance calculation
    const sortedForDisplay = [...filteredTrades].sort((a, b) => 
        new Date(a.timestamp) - new Date(b.timestamp)
    );
    
    // Get initial balance from first trade (if available) or calculate from all trades
    let runningBalance = null;
    const firstTrade = sortedForDisplay[0];
    if (firstTrade) {
        // Check if first trade has initialBalance field
        if (firstTrade.initialBalance) {
            runningBalance = parseFloat(firstTrade.initialBalance);
        } else {
            // Calculate initial balance: first trade's balance + first trade's amount
            const firstBalance = parseFloat(firstTrade.balance || 0);
            const firstAmount = parseFloat(firstTrade.amount || 0);
            if (firstBalance > 0) {
                runningBalance = firstBalance + firstAmount;
            } else {
                // Fallback: use default or calculate from all trades
                runningBalance = 50; // Default
            }
        }
    } else {
        runningBalance = 50; // Default starting balance
    }
    
    tbody.innerHTML = sortedForDisplay.map((trade, index) => {
        const amount = parseFloat(trade.amount || 0);
        const price = parseFloat(trade.price || 0);
        let pnl = parseFloat(trade.pnl || 0);
        let balance = parseFloat(trade.balance || 0);
        
        // Calculate balance if missing or invalid
        if (balance <= 0 || isNaN(balance)) {
            // For BUY: balance decreases by amount
            // For SELL: balance increases by amount
            if (trade.action === 'BUY') {
                balance = runningBalance - amount;
            } else if (trade.action === 'SELL') {
                balance = runningBalance + amount;
            } else {
                balance = runningBalance - amount; // Default to BUY behavior
            }
        }
        
        // Update running balance for next iteration
        runningBalance = balance;
        
        // If P&L is 0 (dry-run), show as "-" or calculate from price movement
        const pnlDisplay = pnl !== 0 ? formatCurrency(pnl) : '-';
        const pnlClass = pnl > 0 ? 'pnl-positive' : (pnl < 0 ? 'pnl-negative' : 'pnl-neutral');
        
        return `
        <tr>
            <td>${formatTimestamp(trade.timestamp)}</td>
            <td>${truncate(trade.market || 'Unknown', 40)}</td>
            <td class="action-${(trade.action || 'BUY').toLowerCase()}">${trade.action || 'BUY'}</td>
            <td>$${formatNumber(price)}</td>
            <td>$${formatCurrency(amount)}</td>
            <td class="${pnlClass}">
                ${pnlDisplay}
            </td>
            <td>$${formatCurrency(balance)}</td>
        </tr>
    `;
    }).join('');
}

// Update balance chart with period filter
function updateChart(period = 'all') {
    if (!balanceChart) return;
    
    // Sort by timestamp
    const sortedTrades = [...tradesData].sort((a, b) => 
        new Date(a.timestamp) - new Date(b.timestamp)
    );
    
    let filteredTrades = sortedTrades;
    
    // Apply period filter
    if (period === '7d') {
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
        filteredTrades = sortedTrades.filter(t => new Date(t.timestamp) >= sevenDaysAgo);
    } else if (period === '24h') {
        const oneDayAgo = new Date();
        oneDayAgo.setHours(oneDayAgo.getHours() - 24);
        filteredTrades = sortedTrades.filter(t => new Date(t.timestamp) >= oneDayAgo);
    }
    
    const labels = filteredTrades.map(t => formatTimestamp(t.timestamp, true));
    const balances = filteredTrades.map(t => t.balance || 0);
    
    balanceChart.data.labels = labels;
    balanceChart.data.datasets[0].data = balances;
    balanceChart.update('none');
}

// Render empty state
function renderEmptyState() {
    updateSummaryCards(0, 0, 0, 0, 0, 0, '-', 0, 0, 0);
    
    const tbody = document.getElementById('tradesBody');
    if (tbody) {
        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="empty">
                    <div style="text-align: center; padding: 40px;">
                        <div style="font-size: 48px; margin-bottom: 20px;">📊</div>
                        <div style="font-size: 18px; font-weight: 600; color: var(--text-primary); margin-bottom: 10px;">
                            No trades yet
                        </div>
                        <div style="font-size: 14px; color: var(--text-secondary); max-width: 400px; margin: 0 auto; line-height: 1.6;">
                            Bot is running in dry-run mode. Trades will appear here once the bot detects arbitrage opportunities.
                        </div>
                    </div>
                </td>
            </tr>
        `;
    }
    
    if (balanceChart) {
        balanceChart.data.labels = [];
        balanceChart.data.datasets[0].data = [];
        balanceChart.update();
    }
    
    if (winRateChart) {
        winRateChart.data.datasets[0].data = [0, 0];
        winRateChart.update();
    }
}

// Helper functions
function formatCurrency(value) {
    return parseFloat(value || 0).toFixed(2);
}

function formatNumber(value) {
    return parseFloat(value || 0).toFixed(4);
}

function formatTimestamp(timestamp, short = false) {
    if (!timestamp) return '-';
    const date = new Date(timestamp);
    if (short) {
        return date.toLocaleTimeString();
    }
    return date.toLocaleString();
}

function truncate(str, maxLength) {
    if (!str) return '-';
    return str.length > maxLength ? str.substring(0, maxLength) + '...' : str;
}

function showError(message) {
    const tbody = document.getElementById('tradesBody');
    if (tbody) {
        tbody.innerHTML = `<tr><td colspan="7" class="empty" style="color: var(--loss);">${message}</td></tr>`;
    }
}
