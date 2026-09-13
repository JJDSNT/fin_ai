# PETR4 — opções ATM do próximo vencimento com OCO pré-preenchida

**Status:** 📝 rascunho · **Criada em:** 2026-09-13

---

## 💡 Ideia

Acompanhar **PETR4** (ativo-objeto) com pelo menos **4 indicadores**. Quando eles concordarem numa direção, um **script no MT5** monta uma operação **pré-preenchida** na opção **quase dentro do dinheiro** (ATM / levemente OTM) do **próximo vencimento**, com **saída OCO** (stop + alvo). A operação só vai para o mercado depois da minha confirmação.

**Regras estruturais:**
- **Uma operação ativa por vez.**
- A operação **começa sempre com compra de call** (sinal de alta).
- **Put só entra como perna protetora** de uma call aberta, com vencimento e quantidade equivalentes. Nunca existe put sozinha, e sinal de baixa **não** abre operação.
- Objetivo da put: travar um **piso no vencimento**. Se a call já andou o suficiente, o pior cenário vira um resultado positivo conhecido, a **"renda fixa"**, mantendo o ganho aberto para os dois lados (seção 6).

## Por que opções?

- **Risco máximo conhecido**: comprando opção, o pior caso é perder o prêmio pago.
- **Alavancagem**: um movimento pequeno em PETR4 vira um movimento percentual maior na opção.
- **Capital menor** do que comprar lotes de ações.

Em troca, a opção perde valor com o tempo (**theta**), tem spread mais largo que a ação e depende da **volatilidade implícita**.

---

## 1. Sinal: 4 indicadores de famílias diferentes

Indicadores da mesma família (RSI, estocástico, MACD) dizem quase a mesma coisa. Quatro indicadores correlacionados valem por um. Proposta com uma família para cada:

| # | Família | Indicador (proposta) | Alta | Baixa |
|---|---|---|---|---|
| 1 | Tendência | EMA 20 × EMA 50 | EMA20 > EMA50 e preço > EMA20 | EMA20 < EMA50 e preço < EMA20 |
| 2 | Momentum | RSI(14) | entre 50 e 70 | entre 30 e 50 |
| 3 | Força da tendência | ADX(14) | ADX > 20 e +DI > −DI | ADX > 20 e −DI > +DI |
| 4 | Volume | volume real vs média de 20 | volume > média, candle de alta | volume > média, candle de baixa |
| ctx | Volatilidade | ATR(14) | define níveis de stop/alvo no ativo | — |

**Regra de entrada (proposta):** tendência (#1) obrigatória **e** pelo menos 2 dos outros 3 a favor, ou seja, **score ≥ 3/4** com o filtro de tendência.

Por que o ADX importa aqui: em mercado lateral, quem compra opção perde para o theta todos os dias. O ADX é o filtro que evita esse cenário.

**Timeframe (proposta):** sinal em **H1**, com o **D1** como filtro de contexto. Horizonte de 2 a 5 pregões. *(ver D4)*

---

## 2. Seleção da opção

| Critério | Regra proposta |
|---|---|
| Ativo-objeto | `SYMBOL_BASIS == "PETR4"` |
| Tipo | call (alta) / put (baixa) — `SYMBOL_OPTION_RIGHT` |
| Vencimento | o mais próximo com **≥ 10 dias úteis** restantes; se tiver menos, pula para o seguinte — `SYMBOL_EXPIRATION_TIME` |
| **Strike ("quase dentro do dinheiro")** | o **mais próximo do preço de PETR4** e seus vizinhos imediatos — `SYMBOL_OPTION_STRIKE` |
| **Quantificação** | delta, gamma e theta de cada candidata, ver abaixo |
| Liquidez | spread ≤ 5% do prêmio e negócios no dia acima de um mínimo |

Tudo isso pode ser lido pelo MQL5, sem digitar ticker manualmente.

### Quantificando com as gregas

O ponto de partida continua sendo o **strike mais próximo** do preço de PETR4. As gregas **quantificam** o que "quase dentro do dinheiro" significa naquele momento. O mesmo strike pode estar mais ou menos "perto" dependendo do preço do ativo, do tempo até o vencimento e da volatilidade, e as gregas mostram isso em número.

| Grega | O que mede | Por que importa para quem **compra** a opção |
|---|---|---|
| **Delta (Δ)** | quanto o prêmio anda para cada R$ 1 em PETR4; ≈ "probabilidade" de terminar ITM | quantifica o quão perto do dinheiro está: ATM ≈ 0,50 (um pouco acima com juros altos); ITM acima, OTM abaixo |
| **Gamma (Γ)** | quanto o delta muda para cada R$ 1 em PETR4 | é a **aceleração**: com gamma alta, um movimento a favor aumenta o delta e o ganho cresce mais que linearmente. É máxima perto do ATM |
| **Theta (Θ)** | quanto o prêmio perde por dia parado | é o **custo de esperar**. Também é máximo perto do ATM e acelera perto do vencimento |
| **Vega (ν)** | quanto o prêmio muda para cada 1 ponto de volatilidade implícita | risco de pagar IV alta e vendê-la mais baixa |

**O trade-off central é gamma × theta.** Exemplo com Black-Scholes, PETR4 = 38,42, IV 28%, juros 14% a.a., 33 dias corridos:

| Strike | Prêmio | Δ | Γ | Θ/dia | Θ em % do prêmio | ν | Γ / \|Θ\| |
|---|---|---|---|---|---|---|---|
| 37,00 (ITM) | 2,42 | 0,74 | 0,101 | −0,026 | −1,1% | 0,038 | 3,9 |
| **38,50 (mais próximo)** | **1,50** | **0,57** | **0,122** | **−0,027** | **−1,8%** | **0,045** | **4,5** |
| 39,00 | 1,25 | 0,51 | 0,123 | −0,027 | −2,1% | 0,046 | 4,6 |
| 40,00 (OTM) | 0,84 | 0,39 | 0,118 | −0,024 | −2,9% | 0,044 | 4,9 |
| 41,00 (OTM) | 0,54 | 0,28 | 0,104 | −0,021 | −3,8% | 0,039 | 5,1 |

E o mesmo strike (38,50) conforme o vencimento se aproxima:

| Dias até o vencimento | Prêmio | Γ | Θ em % do prêmio por dia |
|---|---|---|---|
| 60 | 2,15 | 0,089 | −1,0% |
| 33 | 1,50 | 0,122 | −1,8% |
| 10 | 0,74 | 0,224 | −5,8% |
| 5 | 0,50 | 0,317 | **−11,5%** |

O que a tabela ensina:
- Com juros altos (Selic), o strike igual ao preço à vista já tem **delta > 0,50**. O delta "0,50" fica um pouco acima do preço atual.
- **Γ/|Θ| sobe quanto mais OTM**, mas o prêmio cai e a chance de dar certo também. Por isso a faixa de delta limita a escolha.
- Perto do vencimento, a gamma é explosiva, mas o theta come mais de 10% do prêmio por dia. Só faz sentido para um movimento **imediato**.

**Regra proposta:**
1. **Candidatas**: o strike mais próximo de PETR4 e os vizinhos imediatos (um acima e um abaixo).
2. **Quantificar** cada uma: Δ, Γ, Θ (também em % do prêmio), ν e IV. Mostrar tudo no resumo antes de enviar.
3. **Padrão**: ficar com o **strike mais próximo**, desde que ele passe nas checagens:
   - delta entre **0,40 e 0,60** (calls) ou entre −0,60 e −0,40 (puts)
   - **|Θ| ≤ 3% do prêmio por dia** (complementa a regra de dias úteis até o vencimento)
   - **IV** não muito acima da volatilidade realizada de PETR4 (ex.: IV ≤ 1,3 × volatilidade histórica de 20 dias)
   - liquidez aceitável
4. **Se o mais próximo falhar** numa checagem, usar o vizinho que passar, com **maior Γ/|Θ|** como desempate. Se nenhum passar, **não opera**.
5. **Registrar as gregas na entrada** de cada operação. Com o tempo, o diário mostra quais faixas de delta, gamma e theta deram melhor resultado, e as checagens podem ser recalibradas.

**De onde vêm as gregas:**
- **Da corretora**: `SYMBOL_PRICE_DELTA`, `SYMBOL_PRICE_GAMMA`, `SYMBOL_PRICE_THETA`, `SYMBOL_PRICE_VEGA` e `SYMBOL_PRICE_VOLATILITY` (é o mesmo que aparece no *Quadro de opções* do MT5). Nem toda corretora preenche esses campos.
- **Cálculo próprio**, como alternativa: IV implícita pelo preço médio entre bid e ask (bisseção no Black-Scholes), juros = CDI e tempo em **dias úteis/252** (convenção brasileira). Theta por dia útil e por dia corrido dão números diferentes; escolher uma convenção e manter.
- Black-Scholes é europeu. Para calls americanas de PETR4 é uma boa aproximação, exceto perto de datas ex de dividendos.

### Lembretes sobre opções na B3

- **Vencimento**: 3ª sexta-feira do mês.
- **Código**: `PETR` + letra + número. Letras **A–L = calls** (jan–dez) e **M–X = puts** (jan–dez). O número **não** é o strike; leia o strike pelas propriedades do símbolo.
- **Lote**: 100 opções.
- **Estilo**: em geral, calls são americanas e puts europeias. Confira em `SYMBOL_OPTION_MODE`.
- **Dividendos**: a Petrobras paga proventos altos, e a B3 **ajusta o strike** na data ex. O preço da ação cai na data ex, o que afeta calls.
- **Liquidez**: fica concentrada no vencimento mais próximo e nos strikes perto do dinheiro. Puts costumam ser menos líquidas que calls.

---

## 3. Tamanho da posição

Na compra de opção, a perda máxima é o prêmio. Então o tamanho é definido pelo **prêmio total**, não pelo stop (gaps pulam o stop):

```
prêmio_máximo_R$ = capital × risco%          (proposta: 2%)
quantidade       = prêmio_máximo_R$ / prêmio  → arredonda para BAIXO em lotes de 100
```

Exemplo: capital R$ 10.000, 2% = R$ 200, prêmio R$ 0,80 → 250 → **200 opções** (R$ 160).

Se nem 100 opções couberem no limite, **não opera**.

A **put protetora** usa a mesma quantidade da call e não consome novo orçamento de risco, **desde que o piso seja ≥ 0**: nesse caso o pior cenário da operação deixa de ser perda.

---

## 4. Ordem OCO pré-preenchida

### Como funciona no MT5

O MT5 **não tem ordem OCO nativa** (duas ordens pendentes ligadas). Existem dois caminhos:

| Caminho | Como | Prós | Contras |
|---|---|---|---|
| **A. SL/TP na posição** | ordem de compra já com `sl` e `tp`; o servidor da corretora zera quando um deles é atingido | simples, protege mesmo com o MT5 fechado | stop vira **ordem a mercado** em um livro com spread largo; algumas corretoras não aceitam SL/TP em opções |
| **B. OCO pelo ativo-objeto** | um EA monitora **PETR4** e fecha a opção quando o preço da ação atinge stop ou alvo | o sinal é sobre PETR4, então a saída também faz sentido nele; evita stops disparados por ruído no book da opção | precisa do MT5 ligado (VPS) |

**Proposta:** usar **os dois**.
- **B** é a saída principal: stop e alvo em PETR4, com base no ATR.
- **A** é a proteção de emergência no preço da opção, mais larga (ex.: SL −60% do prêmio).
- Quando a **put protetora** entra, o SL/TP da call é removido e as duas pernas passam a ser fechadas **sempre juntas** (seção 6).

### Fluxo do script (semi-automático)

O script olha primeiro o **estado da operação** (posições e ordens pendentes em opções com `SYMBOL_BASIS == "PETR4"` e o magic da estratégia) e age conforme o caso:

| Estado | O que o script faz |
|---|---|
| Nenhuma operação | fluxo de **entrada na call** (passos abaixo) |
| Ordem de entrada pendente | mostra a ordem e oferece cancelar; **não** abre outra |
| Call aberta, sem put | mostra o status e a **simulação da put protetora** (piso × vender a call × CDI, seção 6); pede confirmação |
| Call + put abertas | mostra o piso travado e o resultado atual; oferece **fechar as duas pernas juntas** |

Fluxo de entrada:

1. Arrasto o script para o gráfico de **PETR4**.
2. O script calcula os 4 indicadores e o score. Só segue com **sinal de alta** (sinal de baixa não abre operação).
3. Escolhe a opção pelas gregas e pela liquidez (seção 2).
4. Calcula entrada (limitada no preço médio entre bid e ask), quantidade, SL/TP da opção e níveis de saída em PETR4.
5. Mostra um resumo e pede confirmação:
   ```
   PETR4 38,42 | Score 3/4  EMA↑  RSI 58  ADX 27  Vol↓
   COMPRA CALL PETRJxxx  strike 38,50 (mais próximo)  venc. 16/10 (~24 d.u.)
   Δ 0,57  Γ 0,122  Θ −0,027/dia (−1,8%)  ν 0,045  IV 28% (HV20 25%)  ✔ checagens ok
   100 × 1,50 = R$ 150,00 (1,5% do capital)
   Saída no ativo:  stop 37,20 | alvo 40,80
   Proteção opção:  SL 0,60 | TP 3,00
   Spread 3,2% · negócios hoje 1.840
   [ Enviar ]  [ Cancelar ]
   ```
6. Se eu confirmar, envia uma ordem **limitada**, `ORDER_TIME_DAY`, preenchimento `RETURN`, com SL/TP.
7. Registra a operação em `MQL5/Files/FinAI/petr4_opcoes.csv` (memória para análise).

Números acima são ilustrativos.

---

## 5. Saída e gestão

- Stop / alvo em PETR4 (principal) com base no ATR, ex.: stop 1,5×ATR e alvo 3×ATR *(a calibrar)*.
- **Saída por tempo**: se não atingir nada em N pregões, zera (o theta está consumindo o prêmio).
- **Saída antes do vencimento**: zerar até X dias úteis antes; não levar ao exercício.
- **Evento**: não abrir posição com resultado trimestral, data ex de dividendos ou decisão relevante da empresa dentro do horizonte da operação.
- **Depois da put protetora**, as saídas mudam (ver seção 6).

---

## 6. Put protetora: travando a "renda fixa"

### A conta

Com uma **call de strike K_call** comprada por `prêmio_call` e uma **put de strike K_put ≥ K_call**, mesmo vencimento e mesma quantidade, o valor das duas no vencimento **nunca é menor que K_put − K_call**, qualquer que seja o preço de PETR4:

| PETR4 no vencimento | Call vale | Put vale | Soma |
|---|---|---|---|
| abaixo de K_call | 0 | K_put − S | **≥ K_put − K_call** |
| entre K_call e K_put | S − K_call | K_put − S | **= K_put − K_call** |
| acima de K_put | S − K_call | 0 | **≥ K_put − K_call** |

```
piso_no_vencimento = (K_put − K_call) − prêmio_call_pago − prêmio_put
```

Se o **piso ≥ 0**, a pior hipótese é um resultado positivo conhecido, e a operação continua ganhando mais se PETR4 andar forte para **qualquer** lado.

### ⚠️ "Equivalente" precisa ser strike da put ACIMA do strike da call

Com o **mesmo strike**, K_put − K_call = 0 e o piso é **−(prêmio_call + prêmio_put)**. Não existe renda fixa nenhuma: é um straddle, que perde tudo se PETR4 terminar no strike. A trava só aparece quando PETR4 já subiu e a put comprada tem strike acima do da call.

**Definição proposta de "put equivalente":** mesmo vencimento, mesma quantidade, strike ≥ strike da call, escolhido entre os strikes perto do preço atual de PETR4 pelas gregas e pelo piso resultante.

### Exemplo

Call 38,50 comprada a **1,50** (seção 4). Faltando 21 dias, IV 28%, juros 14%:

| PETR4 hoje | Put | Custo da put | Piso no vencimento | Vender a call agora |
|---|---|---|---|---|
| 40,30 | 38,50 (mesmo strike) | 0,32 | **−1,82** ❌ | +0,93 |
| 40,30 | 40,50 (mais próximo) | 1,02 | **−0,52** ❌ | +0,93 |
| 40,30 | 42,50 | 2,27 | +0,23 | +0,93 |
| 42,40 | 38,50 (mesmo strike) | 0,07 | **−1,57** ❌ | +2,78 |
| 42,40 | 40,50 | 0,33 | +0,17 | +2,78 |
| 42,40 | **42,50 (mais próximo)** | **1,02** | **+1,48** ✅ | +2,78 |

Resultado no vencimento da última linha (call 38,50 a 1,50 + put 42,50 a 1,02), por opção:

| PETR4 | 34,00 | 38,50 | 40,00 | 42,50 | 46,00 | 50,00 |
|---|---|---|---|---|---|---|
| Resultado | +5,98 | **+1,48** | **+1,48** | **+1,48** | +4,98 | +8,98 |

O que a tabela mostra:
- A proteção só trava renda fixa **depois que PETR4 subiu bem acima do strike da call**. Com PETR4 a 40,30, o strike mais próximo ainda deixa piso negativo.
- **Custo de oportunidade**: vender a call agora dá +2,78 garantido. A put trava +1,48 e troca a diferença pela chance de ganhar mais com um movimento forte. É uma escolha consciente, não um almoço grátis.
- A put só melhora o pior cenário quando **K_put − K_call > prêmio_put**.

### Regras propostas

1. A put só pode ser comprada com uma **call da operação aberta**: mesmo vencimento, mesma quantidade, **K_put ≥ K_call**.
2. Só compra se **piso ≥ piso mínimo** (proposta: ≥ 0, ou seja, "renda fixa na pior hipótese").
3. O script mostra lado a lado: **piso com a put** × **ganho vendendo a call agora** × **CDI do período** sobre o capital empregado.
4. **As pernas andam juntas**: fechar a call obriga a fechar a put no mesmo momento (senão sobra put sozinha, que viola a regra). Ao adicionar a put, o **SL/TP da call no servidor é removido**, porque um stop disparado deixaria a put órfã.
5. **Saída da operação protegida**:
   - movimento forte para qualquer lado → fecha as duas com resultado bem acima do piso
   - perto do vencimento (ex.: 2–3 dias úteis) → fecha as duas no mercado (≈ piso ou melhor)
   - não levar ao exercício sem planejar (ver riscos)
6. Continua sendo **uma operação**: com call + put abertas, nenhuma nova entrada é permitida.

### Pontos de atenção

- **O piso vale no vencimento.** Antes disso, o valor de mercado das duas pode ficar abaixo do piso (spread, volatilidade), mas converge para ele.
- **Dois spreads**: cada perna paga spread na entrada e na saída. Descontar no cálculo do piso (usar ask na compra e bid estimado na saída).
- **Exercício**: se as duas terminarem dentro do dinheiro (PETR4 entre os strikes), o exercício compra ações a K_call e vende a K_put. Isso exige capital/garantia e tem custos de exercício. **Preferível zerar as pernas antes do vencimento.**
- **Dividendos**: a B3 desconta o provento dos **dois** strikes, então K_put − K_call se mantém.
- **Comparar com o CDI**: se o piso travado render menos que o CDI sobre o capital empregado, vender a call é melhor.

---

## 7. ❓ Decisões em aberto

| # | Decisão | Opções | Minha sugestão |
|---|---|---|---|
| D1 | Checagens das gregas sobre o strike mais próximo | faixa de delta, limite de theta/prêmio, IV × HV, desempate | Δ 0,40–0,60, \|Θ\| ≤ 3%/dia, IV ≤ 1,3×HV20, desempate por Γ/\|Θ\| |
| D1b | Fonte das gregas | corretora (`SYMBOL_PRICE_*`) / cálculo próprio | corretora se disponível, cálculo próprio para conferir |
| ~~D2~~ | ~~Operar baixa com puts?~~ | ✅ **decidido**: uma operação por vez; put só como perna protetora de call aberta | — |
| D9 | "Put equivalente" | mesmo strike / strike ≥ da call perto do preço atual | **K_put ≥ K_call**, mesmo vencimento e quantidade (mesmo strike não trava piso) |
| D10 | Quando comprar a put | piso ≥ 0 / piso ≥ X% do ganho atual / sinal de baixa / decisão manual | script calcula e sugere quando **piso ≥ 0**; decisão final manual |
| D11 | Referência de comparação | só piso / piso × vender a call × CDI | mostrar os três lado a lado |
| D3 | "Próximo vencimento" | série mais próxima / série seguinte | mais próxima com ≥ 10 d.u. |
| D4 | Timeframe e horizonte | intraday / swing 2–5 dias | swing em H1 + filtro D1 |
| D5 | Quais 4 indicadores | tabela da seção 1 ou outros | tabela da seção 1 como ponto de partida |
| D6 | Saída | SL/TP na opção / no ativo / ambos | ambos (seção 4) |
| D7 | Risco por operação | 1% / 2% / 3% do capital em prêmio | 2% |
| D8 | Execução | script com confirmação / EA automático | script com confirmação primeiro |

---

## 8. ⚠️ Riscos e limitações

- **Backtest de opções no MT5 é fraco**: o servidor normalmente remove o histórico de opções vencidas. Não dá para rodar o Strategy Tester direto na opção de meses atrás.
- **Theta**: cada dia parado custa dinheiro. O sinal precisa de movimento **rápido**, não só de direção correta.
- **Volatilidade implícita**: comprar opção com IV alta (antes de eventos) e vendê-la depois do evento (IV caindo) pode dar prejuízo **mesmo acertando a direção**.
- **Spread e slippage**: fora dos strikes ATM do vencimento mais próximo, o book é fino.
- **Risco político/empresa**: Petrobras tem gaps por decisões do governo, preço de combustível e dividendos.
- **Demo**: nem toda conta demo B3 tem opções, nem book realista delas.
- **IR**: operações com opções não têm isenção. Swing 15%, day trade 20%.
- **Put protetora**: o piso só vale no vencimento, cada perna paga spread, e o exercício com PETR4 entre os strikes exige capital. Detalhes na seção 6.
- **Perna órfã**: se a call for fechada (stop no servidor, zeragem, erro) e a put continuar aberta, a operação vira aposta na baixa. O código precisa impedir isso.

---

## 9. Plano de validação

1. **🔬 Sinal no ativo**: EA de teste em **PETR4** no Strategy Tester só com os 4 indicadores e saídas por ATR. A pergunta é: o sinal prevê movimentos **grandes e rápidos o suficiente**?
2. **Simulação das opções**: exportar os sinais em Python e estimar o resultado nas opções (Black-Scholes com a IV da época, ou o delta aproximado), **descontando theta e spread**.
3. **🧪 Demo / paper trading**: script com confirmação, registrando cada sinal no diário, **inclusive os não executados**.
4. **Real mínimo**: 1 lote (100 opções) por operação durante algumas semanas.

Critério para avançar de fase: definir **antes** de começar (ex.: ≥ 30 sinais, payoff esperado positivo após custos, drawdown dentro do limite).

---

## 10. Implementação (a fazer)

- [ ] `mql5/Include/FinAI/OptionSelector.mqh`: encontra opções por ativo-objeto, tipo, vencimento e liquidez, e filtra pelas gregas
- [ ] `mql5/Include/FinAI/BlackScholes.mqh`: prêmio teórico, IV implícita e gregas (quando a corretora não fornece)
- [ ] `mql5/Include/FinAI/SignalScore.mqh`: os 4 indicadores e o score
- [ ] `mql5/Experts/FinAI/Petr4SignalTest.mq5`: teste do sinal em PETR4 (etapa 1)
- [ ] `mql5/Include/FinAI/OperacaoPetr4.mqh`: estado da operação (nenhuma / pendente / call / call+put), regra de uma operação por vez, cálculo do piso
- [ ] `mql5/Scripts/FinAI/Petr4Operacao.mq5`: script único com os 4 modos (entrada, proteção, status, fechamento das duas pernas) e confirmação
- [ ] `mql5/Experts/FinAI/Petr4OpcaoGerente.mq5`: saída pelo ativo-objeto (OCO caminho B) e **guarda contra perna órfã** (fecha a put se a call sair)
- [ ] `python/simular_opcoes.py`: estimativa do resultado nas opções a partir dos sinais
